#!/bin/sh
apt-get update 
apt-get install unzip
wget https://releases.hashicorp.com/consul/1.0.6/consul_1.0.6_linux_amd64.zip?_ga=2.264617996.228682823.1520510943-1002964709.1520510943 -O /tmp/consul.zip
unzip -d /tmp/consul.zip -d /usr/local/sbin/
