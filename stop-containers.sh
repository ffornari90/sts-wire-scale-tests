#!/bin/bash
if [[ $# -eq 0 ]] ; then
    echo 'ERROR: You must provide a client number.'
    exit 0
fi
CLI_NUM=$(($1 / 4))
for ((index=0; index != $(($CLI_NUM * 4)); index=$(($index + 4)))); do
  wassh -f client-hosts -l root 'CLI_INDEX=$(expr '$(($index + 1))' + $CLIENT_X_FACTOR) && docker stop sts-wire-client$CLI_INDEX && docker rm sts-wire-client$CLI_INDEX'
done