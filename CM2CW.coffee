request = require 'request'
aws     = require 'aws-sdk'

config  =
  environment: process.env.NODE_ENV             or 'development'
  region:      process.env.AWS_REGION           or 'us-east-1'
  namespace:   process.env.CLOUDWATCH_NAMESPACE or 'Cloudera'
  hostname:    process.env.CLOUDERA_HOSTNAME    or 'http://hadoop-manager.uat.i-edo.net'
  port:        process.env.CLOUDERA_API_PORT    or 7180
  clustername: process.env.CLOUDERA_CLUSTERNAME
  username:    process.env.CLOUDERA_USERNAME    or 'admin'
  password:    process.env.CLOUDERA_PASSWORD

baseurl = config.hostname+':'+config.port+'/api/v9/clusters/'

unless config.password?
  console.log 'Please set CLOUDERA_PASSWORD environment variable'
  process.exit(1)

cloudwatch = new (aws.CloudWatch)
  region: config.region
  apiVersion: '2010-08-01'

#=========================================
baseURLoptions =
  method: 'GET'
  url: baseurl
  headers: 'authorization': "Basic " + new Buffer(config.username + ':' + config.password).toString("base64")

request baseURLoptions, (error, response, body) ->
  throw new Error(error) if error
  for item in JSON.parse(body).items
    clustername = item.displayName+'/services'
    finalurl = baseurl+clustername
    console.log finalurl

# unless config.clustername?
#   console.log 'CLOUDERA_CLUSTERNAME not set; Deriving from first array element "items[0].displayName:"'
# #=========================================

options =
  method: 'GET'
  url: finalurl
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
