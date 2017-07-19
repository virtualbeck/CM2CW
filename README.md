# CM2CW
Send **C**loudera **M**anager services' health data to AWS **C**loud**W**atch

## Install
Download binary from `https://github.com/virtualbeck/CM2CW/releases`, extract,  and execute. Enjoy!

## Options and Defaults
These variables will be user-defined at the time of running the binary. If not defined, the defaults will be used.

Name | Default
:---:|:---:
`NODE_ENV` | `development`
`AWS_REGION` | `us-east-1`
`CLOUDWATCH_NAMESPACE` | `Cloudera`
`CLOUDERA_USERNAME` | `admin`
`CLOUDERA_PASSWORD` | **none**
`CLOUDERA_API_URL` | **none**

- Supports Cloudera Enterprise >= 5.3.x
- Example command:
- `CLOUDERA_API_URL='http://cm-qa.mycompany.com:7180/api/v9/clusters/myQACluster/services/' CLOUDERA_PASSWORD=12345 CM2CW`

### Development
- Clone repository
- `npm install && npm run build`
