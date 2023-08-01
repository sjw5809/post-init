#!/bin/bash

echo deb http://archive.ubuntu.com/ubuntu/ focal main >> /etc/apt/sources.list
apt-get update
apt-get install -y libc6 nvidia-opencl-dev screen htop

jupyter server list

