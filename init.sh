#!/bin/bash

atxid=9eebff023abb17ccb775c602daade8ed708f0a50d3149a42801184f5b74f2865
numunit=$1
fromfile=$2
tofile=$3
nodeid=$4

#准备文件夹
echo start
cd /root
mkdir /root/tran
mkdir /root/tran/01
mkdir /root/tran/data
mkdir /root/tran/wait
mkdir /root/tran/keepalive
cd /root/tran
#准备环境
echo deb http://archive.ubuntu.com/ubuntu/ focal main >> /etc/apt/sources.list
apt-get update
apt-get install -y libc6 nvidia-opencl-dev screen
chmod 755 *

#输出token
jupyter server list
#有参数后台开始
echo numunit $numunit
if [ $numunit -gt 0 ]
then
  screen -dmS tran
  screen -x -S tran -p 0 -X stuff "/root/tran/postcli -numUnits $numunit -fromFile $fromfile -toFile $tofile -commitmentAtxId=$atxid -id $nodeid -maxFileSize 1073741824 -provider 0 -datadir /root/tran/01 \n"
fi

#完成文件移动
while true
do
 for aa in $(ls -s /root/tran/01 | awk '/1048576/{print $2}')
 do
   num=$(echo $aa |sed -r 's/^[^0-9]+([0-9]+).*/\1/')
   mm5=$(md5sum /root/tran/01/$aa)
   name=${mm5:0:9}$num.pth.gz
  echo $(date +%H:%M:%S) $aa $name $(df -h | awk  '/.local/{print $4}')
  echo 1 >>/root/tran/wait/$name
  mv /root/tran/01/$aa /root/tran/data/$name
 done
done
