#!/bin/bash

numunit=$1
fromfile=$2
tofile=$3
nodeid=$4
atxid=$5

 for aa in $(ls -s /root/tran/01 | grep bin )
 do
   fromfile2=$(echo $aa |sed -r 's/^[^0-9]+([0-9]+).*/\1/')
 done
if [ $fromfile2 -gt 0 ]
then
 fromfile=$fromfile2
 rm /root/tran/01/postdata_${fromfile2}.bin
fi

./init.sh $numunit $fromfile $tofile $nodeid $atxid
