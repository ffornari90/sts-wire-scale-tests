#!/bin/bash
ROOTDIR=$(git rev-parse --show-toplevel)
if [[ $# -eq 0 ]] ; then
    echo 'ERROR: You must provide a number of clients.'
    exit 1
fi
mkdir -p $ROOTDIR/scripts/sts-wire/conf/configs
for i in $(seq 1 $1)
do
echo '---
IAM_Server: https://131.154.96.40.myip.cloud.infn.it
instance_name: myRGW
s3_endpoint: https://rgw.90.147.174.123.myip.cloud.infn.it
role_name: S3AccessIAMDouble
audience: https://wlcg.cern.ch/jwt/v1/any
rclone_remote_path: /client'$i'
local_mount_point: ./rgw
log: ./sts-wire.log
noPassword: true
refreshTokenRenew: 15
insecureConn: true' | \
tee $ROOTDIR/scripts/sts-wire/conf/configs/config-$i.yml
done
