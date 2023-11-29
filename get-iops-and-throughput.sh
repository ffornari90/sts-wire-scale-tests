cat $1/sts-wire-client* | grep IOPS | awk '{gsub(/[IOPS=,()k]/," "); print $2" "$5}' | awk '{if ($0 !~ /MB\/s/) {print $1" "$2/1000} else {print $1" "$2}}' | awk -F"MB/s" '{print $1" "$2}'
