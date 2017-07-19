request = require('request')
aws = require('aws-sdk')
config = require('./env.json')[process.env.NODE_ENV or 'qa']


cloudwatch = new (aws.CloudWatch)
  region: 'us-east-1'
  apiVersion: '2010-08-01'

password = config.password

unless password?
  console.log 'Please define a password'
  process.exit(1)

options =
  method: 'GET'
  url: config.url
  headers: 'authorization': "Basic " + new Buffer(config.username + ':' + password).toString("base64")
request options, (error, response, body) ->
  if error
    throw new Error(error)
  obj = JSON.parse(body)
  for item in obj.items
    for healthcheck in item.healthChecks
      unless healthcheck.suppressed
        params =
          MetricData: [ {
            MetricName: 'ClouderaServiceStatus'
            Dimensions: [ {
              Name: 'healthcheck_name'
              Value: healthcheck.name
              }
              {
              Name: 'environment'
              Value: config.environment
              } ]
            Timestamp: new Date
            Value: (if healthcheck.summary == 'GOOD' then 1 else 0)
          } ]
          Namespace: 'Cloudera'
        cloudwatch.putMetricData params, (err, data) ->
          if err
            console.log err, err.stack
          else
            console.log data
          # successful response
          return
