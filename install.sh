#!/bin/bash

#ubuntu 18.04

color=`tput setaf 2`

reset=`tput sgr0`

echo "${color}ZCore Blockbook Installer${reset}"

sleep 1

read -p "${color}Please insert the coin ticker you want to build:${reset} " ticker

read -p "${color}please insert the domain name:${reset} " domain

echo "${color}Adding some swap space..${reset}"

sleep 1

fallocate -l 2G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile

sleep 1

echo "${color}Building system dependencies........${reset}"

sleep 1

add-apt-repository ppa:bitcoin/bitcoin -y && apt-get update && apt-get install git apt-transport-https ca-certificates curl gnupg-agent software-properties-common build-essential libtool autotools-dev autoconf pkg-config libssl-dev libevent-dev automake libminiupnpc-dev libdb4.8-dev libdb4.8++-dev nginx libboost-program-options-dev -y

sleep 1

echo "${color}Installing Docker......${reset}"

sleep 1

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - 

add-apt-repository -y \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update && apt-get install docker-ce docker-ce-cli containerd.io -y

sleep 1

echo "${color}Building Blockbook....${reset}"

sleep 1

git clone https://github.com/mosqueiro/blockbook-coins.git && cd blockbook-coins && make all-${ticker}

sudo chown _apt /var/lib/update-notifier/package-data-downloads/partial/

apt install /root/blockbook-coins/build/*.deb -y

sleep 1

echo "${color}Installing certbot.....${reset}"

sleep 1

add-apt-repository ppa:certbot/certbot -y && apt install python-certbot-nginx -y && ufw allow 'Nginx Full' && certbot --nginx -d ${domain}

echo "${color}Updating NGINX conf file...${reset}"

sleep 1

:> /etc/nginx/sites-enabled/default

tee -a /etc/nginx/sites-enabled/default << END



server {
        server_name ${domain};
        location / {        
        proxy_pass https://localhost:9130;
     if ($request_method = 'OPTIONS') {
        add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
        #
        # Custom headers and headers various browsers *should* be OK with but aren't
        #
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
        #
        # Tell client that this pre-flight info is valid for 20 days
        #
        add_header 'Access-Control-Max-Age' 1728000;
        add_header 'Content-Type' 'text/plain; charset=utf-8';
        add_header 'Content-Length' 0;
        return 204;
     }
     if ($request_method = 'POST') {
        add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
        add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range';
     }
     if ($request_method = 'GET') {
        add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
        add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range';
     }        
    }


    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/${domain}/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/${domain}/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}
server {

        server_name ${domain};
        location / {
        proxy_pass https://localhost:9130;
    }

    listen 80;
    return 301 https://$host$request_uri;
}


END

service nginx restart

sleep 1

echo "${color}Installation completed, you can now start backend and blockbook services${reset}"