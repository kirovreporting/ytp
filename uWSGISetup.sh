#!/bin/bash

###################################################################################
#
# Как видно по всем этим командам, тут устанавливается uwsgi-сервер и всё прочее, 
# но ничего не мешает остановиться после пятой строчки и запустить всё на тестовом 
# сервере командой 'python3 /root/ytpserver.py', предварительно поправив внутри 
# ip и порт, закрыть виртуалку и уйти по своим делам.
#
###################################################################################

read -p "Enter domain name for your proxy (like this: youtube.proxy.com): " domainName
read -p "Enter email for certbot notifications: " certbotMail

echo "creatind directories..."
cd /root
mkdir ytp
cd ytp
mkdir templates

echo "installing binaries for python and uWSGI..."
apt -yq update
apt -yq install wget build-essential python3-dev python3-pip 
pip3 -q install uwsgi flask

echo "downloading project from git..."
wget ''

echo "creating uWSGI config file..."
cat << EOF > uwsgi.ini
[uwsgi]
module = wsgi:app

master = true
processes = 5
wsgi-file = /root/ytp/ytpServer.py
socket = /tmp/ytp.sock
chmod-socket = 660
vacuum = true

die-on-term = true
EOF

echo "registering and starting uWSGI service..."
cat << EOF > /etc/systemd/system/uwsgi.service
[Unit]
Description=uWSGI instance
After=network.target

[Service]
Group=www-data
WorkingDirectory=/root/ytp/
ExecStart=/usr/local/bin/uwsgi --ini /root/ytp/uwsgi.ini
Restart=always
KillSignal=SIGQUIT
Type=notify
NotifyAccess=all

[Install]
WantedBy=multi-user.target
EOF
systemctl start uwsgi
systemctl enable uwsgi

echo "installing nginx..."
apt -yq install nginx

echo "creating nginx config..."
cat << EOF > /etc/nginx/sites-available/ytp
server {
    listen 80;
    server_name ${domainname};

    location / {
        include uwsgi_params;
        uwsgi_pass unix:/root/ytp/ytp.sock;
    }
}
EOF
unlink /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/ytp /etc/nginx/sites-enabled

echo "starting nginx..."
systemctl restart nginx

echo "installing certbot..."
apt -yq install certbot python3-certbot-nginx

echo "issuing certs..."
certbot --nginx -d $domainName --non-interactive --agree-tos -m $certbotMail

echo "done. bye!"
exit 0