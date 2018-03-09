#!/bin/sh
apt-get update 
apt-get install unzip
wget https://releases.hashicorp.com/consul/1.0.6/consul_1.0.6_linux_amd64.zip?_ga=2.264617996.228682823.1520510943-1002964709.1520510943 -O /tmp/consul.zip
unzip /tmp/consul.zip -d /tmp/
cp -a /tmp/consul /usr/local/sbin/
rm -rf /tmp/consul*
mkdir /etc/consul.d
systemctl stop ufw 
systemctl disable ufw

cat > /etc/systemd/system/consul.service << EOF

[Unit]
Description=consul agent
Requires=network-online.target
After=network-online.target

[Service]
EnvironmentFile=-/etc/sysconfig/consul
Environment=GOMAXPROCS=2
Restart=on-failure
ExecStart=/usr/local/sbin/consul agent -server -bootstrap-expect=2 \
    -data-dir=/tmp/consul -bind=`ifconfig | grep "inet addr:10" | cut -d ":" -f 2 | cut -d " " -f 1` \
    -enable-script-checks=true -config-dir=/etc/consul.d
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target

EOF

systemctl daemon-reload

systemctl start consul
