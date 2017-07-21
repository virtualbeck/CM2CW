# CM2CW
Send Cloudera Manager services' health data to AWS CloudWatch

## Install
Download binary from `https://github.com/virtualbeck/CM2CW/releases`,execute and enjoy sweet metrics!

## Options and Defaults
These variables will be user-defined at the time of running the binary. If not defined, the defaults will be used.

Name | Default
:---:|:---:
`NODE_ENV` | `development`
`AWS_REGION` | `us-east-1`
`CLOUDWATCH_NAMESPACE` | `Cloudera`
`CLOUDWATCH_HOSTNAME` | `localhost`
`CLOUDWATCH_PORT` | `7180`
`CLOUDERA_USERNAME` | `admin`
`CLOUDERA_PASSWORD` | **none**
`CLOUDERA_CLUSTERNAME` | **none**

- Supports Cloudera Enterprise >= 5.3.x
- Example command:
- `CLOUDERA_CLUSTERNAME=myProdCluster CLOUDERA_PASSWORD=12345 CM2CW-linux`

### Development
- Clone repository
- `npm install && npm run build`
