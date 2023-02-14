#!/bin/bash

###################################################################################
#
# Как видно по всем этим командам, тут устанавливается uwsgi-сервер и всё прочее, 
# но ничего не мешает просто загрузить файл .py и запустить всё на тестовом 
# сервере командой 'python3 /root/ytpserver.py', предварительно поправив внутри 
# app.run, ip и порт, закрыть виртуалку и уйти по своим делам.
#
# As you can see from all these commands, a uwsgi server is being installed here,
# but nothing holds you from just downloading the .py file and running it on the 
# test server with 'python3 /root/ytpserver.py' command, having previously corrected
# app.run, ip and port inside, then close the virtual machine and move along.
#
###################################################################################

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

read -p "Enter domain name for your proxy (like this: youtube.proxy.com): " domainName
read -p "Enter email for certbot notifications: " certbotMail

echo "updating repos..."
apt -yqq update > /var/log/youtubeproxy.install.log 2>&1
echo "installing binaries for unzipping, python and uWSGI..."
apt -yqq install wget unzip build-essential python3-dev python3-pip > /var/log/youtubeproxy.install.log 2>&1
echo "installing Flask..."
pip install uwsgi > /var/log/youtubeproxy.install.log 2>&1
echo "installing uWSGI..."
pip install flask > /var/log/youtubeproxy.install.log 2>&1

echo "downloading project from git..."
cd /root
wget 'https://github.com/kirovreporting/ytp/archive/refs/heads/master.zip' > /var/log/youtubeproxy.install.log 2>&1
unzip master.zip > /var/log/youtubeproxy.install.log 2>&1
mv ytp-master ytp > /var/log/youtubeproxy.install.log 2>&1
cd ytp

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
apt -yqq install certbot python3-certbot-nginx > /var/log/youtubeproxy.install.log 2>&1

echo "issuing certs..."
certbot --nginx -d $domainName --non-interactive --agree-tos -m $certbotMail > /var/log/youtubeproxy.install.log 2>&1

echo "done. bye!"
exit 0