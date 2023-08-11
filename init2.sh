#!/bin/bash

numunit=$1
fromfile=$2
tofile=$3
nodeid=$4

 for aa in $(ls -s /root/tran/01 | grep bin )
 do
   fromfile2=$aa
 done
if [ -n $fromfile2 ]
then
 fromfile=$fromfile2
fi

echo ./init.sh $numunit $fromfile $tofile $nodeid
