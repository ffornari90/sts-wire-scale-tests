#!/bin/bash -x
if [[ $# -eq 0 ]] ; then
    echo 'ERROR: You must provide a number of clients.'
    exit 0
fi
CLI_NUM=$(($1 / 4))
for ((index=0; index != $(($CLI_NUM * 4)); index=$(($index + 4)))); do
  wassh -f client-hosts -l root 'CLI_INDEX=$(expr '$(($index + 1))' + $CLIENT_X_FACTOR) && cd /root/sts-wire-scale-tests && ./scripts/sts-wire/docker-sts-wire-mount.sh $CLI_INDEX'
done