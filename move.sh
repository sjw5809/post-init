#!/bin/bash

mkdir /root/tran/01
mkdir /root/tran/data
mkdir /root/tran/wait
mkdir /root/tran/keepalive

echo $(date +%H:%M:%S)

while true
do
 for aa in $(ls -s /root/tran/01 | awk '/1048576/{print $2}')
 do
   num=$(echo $aa |sed -r 's/^[^0-9]+([0-9]+).*/\1/')
   name=tran$num.pth.gz
  echo $(date +%H:%M:%S) $aa $name $(df -h | awk  '/.local/{print $4}')
  echo 1 >>/root/tran/wait/$name
  mv /root/tran/01/$aa /root/tran/data/$name
 done
if pgrep postcli > /dev/null; then
 sleep 60
else
 echo keepalive
 rm -rf /root/tran/keepalive/*
 sleep 60
 ./postcli -numUnits 4 -labelsPerUnit  4194304 -commitmentAtxId=9eebff023abb17ccb775c602daade8ed708f0a50d3149a42801184f5b74f2865 -provider 0 -datadir /root/tran/keepalive
fi
done
