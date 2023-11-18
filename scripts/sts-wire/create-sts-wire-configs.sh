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
IAM_Server: https://iam-test.cloud.infn.it
instance_name: myRGW
s3_endpoint: https://rgw.cloud.infn.it
role_name: IAMaccess-test-wlcg
audience: object
rclone_remote_path: /client'$i'
local_mount_point: ./rgw
log: ./sts-wire.log
noPassword: true
refreshTokenRenew: 15
insecureConn: true' | \
tee $ROOTDIR/scripts/sts-wire/conf/configs/config-$i.yml
done
