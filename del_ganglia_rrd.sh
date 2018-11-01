#!/bin/bash
# delete compute node rrd files from master; they grow

nodes=($(hostname |  cut -d. -f1))
nodes+=($(qhost | awk '/ip-/{print $1}' | cut -d. -f1))

for n in `ls /var/lib/ganglia/rrds/cfncluster-vpchpc/ | grep ip-`; do
    echo $n
        h=$(echo $n | awk '/ip-/{print $1}' | cut -d. -f1)
        echo $h
    if grep -q $h <<< "${nodes[@]}"; then continue; fi
    sudo rm -fR /var/lib/ganglia/rrds/cfncluster-vpchpc/$n
done
