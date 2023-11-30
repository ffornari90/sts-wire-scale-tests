#!/bin/bash -x
if ! [[ $# -eq 3 ]] ; then
    echo 'ERROR: You must provide the correct number of parameters (client number, file size and block size in this order).'
    exit 0
fi
declare -a pids
CLI_NUM=$(($1 / 4))
FILE_SIZE=$2
BLOCK_SIZE=$3
for count in $(seq 1 3)
do
  mkdir -p /sts-wire-scale-tests/fio_output/$1_clients/sequential/read/$count
  for ((index=0; index != $(($CLI_NUM * 4)); index=$(($index + 4)))); do
    wassh -f client-hosts -l root 'CLI_INDEX=$(expr '$(($index + 1))' + $CLIENT_X_FACTOR) && docker exec sts-wire-client$CLI_INDEX sh -c "sleep 30 && cd /home/docker/rgw && rm -f seqread.0.0 && fio --name=seqread --rw=read --direct=1 --ioengine=libaio --bs="'$BLOCK_SIZE'" --size="'$FILE_SIZE'" --iodepth=64"' > /sts-wire-scale-tests/fio_output/$1_clients/sequential/read/$count/"sts-wire-client"$(($index + 1))"-seq-read.log" 2>&1 & pids+=($!)
  done
  for pid in "${pids[@]}"; do
    wait "$pid"
  done
  sleep 240
  pids=()
  for ((index=0; index != $(($CLI_NUM * 4)); index=$(($index + 4)))); do
    wassh -f client-hosts -l root 'CLI_INDEX=$(expr '$(($index + 1))' + $CLIENT_X_FACTOR) && docker exec sts-wire-client$CLI_INDEX sh -c "cd /home/docker/rgw && rm -f seqread.0.0"' & pids+=($!)
  done
  for pid in "${pids[@]}"; do
    wait "$pid"
  done
done
