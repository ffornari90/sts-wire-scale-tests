#!/bin/bash
if [[ $# -eq 0 ]] || [[$# -eq 1]] || [[$# -eq 2]] ; then
    echo 'ERROR: You must provide the correct number of parameters (client number, file size and block size in this order).'
    exit 0
fi
declare -a pids
CLI_NUM=$(($1 / 4))
FILE_SIZE=$2
BLOCK_SIZE=$3
for count in $(seq 1 3)
do
  mkdir -p $1_clients/random/$count
  for ((index=0; index != $(($CLI_NUM * 4)); index=$(($index + 4)))); do
    wassh -f client-hosts -l root 'CLI_INDEX=$(expr '$(($index + 1))' + $CLIENT_X_FACTOR) && docker exec sts-wire-client$CLI_INDEX sh -c "cd /home/docker/rgw && rm -f test-4m.0 && fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test-4m --filename=test-4m.0 --bs="'$BLOCK_SIZE'" --iodepth=64 --size="'$FILE_SIZE'" --readwrite=randrw --rwmixread=75"' > $1_clients/random/$count/"sts-wire-client"$(($index + 1))"-rand-readwrite.log" 2>&1 & pids+=($!)
  done
  for pid in "${pids[@]}"; do
    wait "$pid"
  done
  sleep 180
  pids=()
  for ((index=0; index != $(($CLI_NUM * 4)); index=$(($index + 4)))); do
    grep read: $1_clients/random/$count/"sts-wire-client"$(($index + 1))"-rand-readwrite.log" | awk '{gsub(/[IOPS=,(MB/s]/," "); print $2, $6}' > $1_clients/random/$count/"sts-wire-client"$(($index + 1))"-rand-read.log" 2>&1
    grep write: $1_clients/random/$count/"sts-wire-client"$(($index + 1))"-rand-readwrite.log" | awk '{gsub(/[IOPS=,(MB/s]/," "); print $2, $6}' > $1_clients/random/$count/"sts-wire-client"$(($index + 1))"-rand-write.log" 2>&1
    wassh -f client-hosts -l root 'CLI_INDEX=$(expr '$(($index + 1))' + $CLIENT_X_FACTOR) && docker exec sts-wire-client$CLI_INDEX sh -c "cd /home/docker/rgw && rm -f test-4m.0"' & pids+=($!)
  done
done


