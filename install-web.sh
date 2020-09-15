#!/bin/bash

#ubuntu 18.04

color=`tput setaf 2`

reset=`tput sgr0`

echo "${color}ZCore Blockbook Installer${reset}"

sleep 1

read -p "${color}Please insert the coin ticker you want to build:${reset} " ticker

read -p "${color}please insert the domain name:${reset} " domain

# fallocate -l 2G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile

# sleep 1

echo "${color}Building system dependencies........${reset}"

sleep 1

add-apt-repository ppa:bitcoin/bitcoin -y && apt-get update && apt-get install git screen nano bash-completion sshpass zram-config apt-transport-https ca-certificates curl gnupg-agent software-properties-common build-essential libtool autotools-dev autoconf pkg-config libssl-dev libevent-dev automake libminiupnpc-dev libdb4.8-dev libdb4.8++-dev nginx libboost-program-options-dev -y

sleep 1

echo "${color}Adding some swap space..${reset}"

sleep 1

sed -i 's/totalmem \/ 2/totalmem * 2/g' /usr/bin/init-zram-swapping

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

#echo "${color}Building Blockbook....${reset}"

#sleep 1

#git clone https://github.com/mosqueiro/blockbook-coins.git && cd blockbook-coins && make all-${ticker}

#sudo chown _apt /var/lib/update-notifier/package-data-downloads/partial/

#apt install /root/blockbook-coins/build/*.deb -y

#sleep 1

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

                add_header Access-Control-Allow-Origin '*' always;

                proxy_pass https://${domain}:9130;

                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header Host $http_host;
                proxy_set_header X-NginX-Proxy true;

                # Enables WS support
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "upgrade";
                proxy_redirect off;
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
