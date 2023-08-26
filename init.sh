#!/bin/bash

numunit=$1
fromfile=$2
tofile=$3
nodeid=$4
atxid=$5

#准备文件夹
echo start
#输出token
jupyter server list
cd /root
mkdir /root/tran
mkdir /root/tran/01
mkdir /root/tran/data
mkdir /root/tran/wait
mkdir /root/tran/keepalive
cd /root/tran
chmod 755 /root/tran/*
chmod 755 /root/tran/deb/*
#准备环境
echo deb http://archive.ubuntu.com/ubuntu/ focal main >> /etc/apt/sources.list
apt-get update

dpkg -i /root/tran/deb/libtinfo6_6.2-0ubuntu2_amd64.deb
dpkg -i /root/tran/deb/libutempter0_1.1.6-4_amd64.deb
dpkg -i /root/tran/deb/screen_4.8.0-1_amd64.deb

dpkg -i /root/tran/deb/libnvidia-compute-530_530.41.03-0ubuntu0.18.04.2_amd64.deb
dpkg -i /root/tran/deb/opencl-c-headers_2.2~2019.08.06-g0d5f18c-1_all.deb
dpkg -i /root/tran/deb/ocl-icd-opencl-dev_2.2.11-1ubuntu1_amd64.deb
dpkg -i /root/tran/deb/nvidia-opencl-dev_9.1.85-3ubuntu1_amd64.deb

dpkg -i /root/tran/deb/gcc-10-base_10-20200411-0ubuntu1_amd64.deb
dpkg -i /root/tran/deb/libgcc-s1_10-20200411-0ubuntu1_amd64.deb
dpkg -i /root/tran/deb/libc6-dbg_2.31-0ubuntu9_amd64.deb
dpkg -i /root/tran/deb/libc-dev-bin_2.31-0ubuntu9_amd64.deb
dpkg -i /root/tran/deb/libc6-dev_2.31-0ubuntu9_amd64.deb
dpkg -i /root/tran/deb/libcrypt-dev_1%3a4.4.10-10ubuntu4_amd64.deb
dpkg -i /root/tran/deb/libcrypt1_1%3a4.4.10-10ubuntu4_amd64.deb
dpkg -i /root/tran/deb/libc6_2.31-0ubuntu9_amd64.deb
dpkg -i /root/tran/deb/libc-bin_2.31-0ubuntu9_amd64.deb
dpkg -i /root/tran/deb/libidn2-0_2.2.0-2_amd64.deb

apt -y --fix-broken install
apt-get install -y libc6 nvidia-opencl-dev screen

#输出token
jupyter server list
#有参数后台开始
echo numunit $numunit
if [ $numunit -gt 0 ]
then
  screen -X quit
  screen -dmS tran
  screen -x -S tran -p 0 -X stuff "/root/tran/postcli -numUnits $numunit -fromFile $fromfile -toFile $tofile -commitmentAtxId=$atxid -id $nodeid -maxFileSize 1073741824 -provider 0 -datadir /root/tran/01 \n"
  screen -x -S tran -p 0 -X stuff "sleep 120 && mv /root/tran/01/postdata_metadata.json /root/tran/data/tran_${tofile}.json.gz && echo 1 >>/root/tran/wait/tran_${tofile}.json.gz \n"
fi

#完成文件移动
while true
do
 sleep 60
 for aa in $(ls -s /root/tran/01 | grep bin | awk '/1048576/{print $2}')
 do
   num=$(echo $aa |sed -r 's/^[^0-9]+([0-9]+).*/\1/')
   mm5=$(md5sum /root/tran/01/$aa)
   name=${mm5:0:9}$num.pth.gz
  echo $(date +%H:%M:%S) $aa $name $(df -h | awk  '/.local/{print $4}')
  echo 1 >>/root/tran/wait/$name
  mv /root/tran/01/$aa /root/tran/data/$name
 done
if pgrep postcli > /dev/null; then
 sleep 60
else
 echo keepalive
 rm -rf /root/tran/keepalive/*
 sleep 5
 /root/tran/postcli -numUnits 4 -labelsPerUnit  1073741824 -commitmentAtxId=9eebff023abb17ccb775c602daade8ed708f0a50d3149a42801184f5b74f2865 -provider 0 -datadir /root/tran/keepalive
fi
done
