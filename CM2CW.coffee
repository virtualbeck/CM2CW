request = require 'request'
aws     = require 'aws-sdk'

config = 
  environment: process.env.NODE_ENV             or 'development'
  region:      process.env.AWS_REGION           or 'us-east-1'
  namespace:   process.env.CLOUDWATCH_NAMESPACE or 'Cloudera'
  username:    process.env.CLOUDERA_USERNAME    or 'admin'
  password:    process.env.CLOUDERA_PASSWORD
  url:         process.env.CLOUDERA_API_URL

unless config.password?
  console.log 'Please set CLOUDERA_PASSWORD environment variable'
  process.exit(1)

unless config.url?
  console.log 'Please set CLOUDERA_API_URL environment variable'
  process.exit(1)
  
cloudwatch = new (aws.CloudWatch)
  region: config.region
  apiVersion: '2010-08-01'

options =
  method: 'GET'
  url: config.url
  headers: 'authorization': "Basic " + new Buffer(config.username + ':' + config.password).toString("base64")

metricData = []

request options, (error, response, body) ->
  throw new Error(error) if error

  for item in JSON.parse(body).items
    for healthcheck in item.healthChecks
      unless healthcheck.suppressed
        metricData.push 
          Dimensions: [
            {
              Name: 'healthcheck_name'
              Value: healthcheck.name
            }
            {
              Name: 'environment'
              Value: config.environment
            } 
          ]
          Value: (if healthcheck.summary == 'GOOD' then 1 else 0)
          MetricName: 'ClouderaServiceStatus'

  while metricData.length > 0
    truncatedMetricData = metricData.slice(0,20)
    metricData = metricData.slice(20)

    cloudwatch.putMetricData {
        Namespace: config.namespace
        MetricData: truncatedMetricData
      }, (err, data) ->
        console.log err, err.stack if err
        console.log data if data
