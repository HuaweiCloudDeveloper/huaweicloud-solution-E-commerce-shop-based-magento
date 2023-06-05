#!/bin/bash
DOMAIN_URL=$1
DB_HOST_IP=$2
DB_NAME=$3
DB_USER=$4
DB_PW=$5
MAGENTO_ADMIN_USER=$6
MAGENTO_ADMIN_PW=$7
MAGENTO_ADMIN_EMAIL=$8
MAGENTO_ADMIN_FIRSTNAME=$9
MAGENTO_ADMIN_LASTNAME=$10

apt-get -y install software-properties-common

add-apt-repository -y ppa:ondrej/php

apt-get -y update

apt-get -y install php7.2

apt-get install -y php7.2-mcrypt php7.2-fpm php7.2-curl php7.2-mysql php7.2-cli php7.2-xsl php7.2-json php7.2-intl php7.2-dev php-pear php7.2-mbstring php7.2-common php7.2-zip php7.2-gd php-soap curl libcurl4  php7.2-bcmath php7.2-xmlwriter php7.2-mbstring php7.2-mysql php7.2-soap php7.2-bcmath php7.2-xml php7.2-mbstring php7.2-gd php7.2-common php7.2-cli php7.2-curl php7.2-intl php7.2-zip zip unzip zlibc

apt-get -y install nginx

rm /usr/share/nginx/html/index.html

mkdir /var/www/magento2

cd /var/www/magento2

wget https://documentation-samples.obs.cn-north-4.myhuaweicloud.com/solution-as-code-publicbucket/solution-as-code-moudle/e-commerce-shop-based-magento/open-source-software/Magento-CE-2.3.0_sample_data-2018-11-27-10-31-01.zip

unzip Magento-CE-2.3.0_sample_data-2018-11-27-10-31-01.zip

chmod 777 /var/www/magento2/bin/magento

chown -R www-data:www-data /var/www/magento2 

#chmod 777 /var/www/magento2/bin/magento

cat > /etc/nginx/sites-available/magento << EOF
upstream fastcgi_backend {
    server  unix:/run/php/php7.2-fpm.sock;
}

server {
    listen 80;
    server_name ${DOMAIN_URL};
    set \$MAGE_ROOT /var/www/magento2;
    set \$MAGE_MODE developer;
    include /var/www/magento2/nginx.conf.sample;
}
EOF

ln -s /etc/nginx/sites-available/magento /etc/nginx/sites-enabled/

apt remove apache2 -y

systemctl restart nginx

/var/www/magento2/bin/magento setup:install --backend-frontname="admin" \
--key="cja8Jadsjwoqpgk93670Dfhu47m7rrIp" \
--db-host="${DB_HOST_IP}" \
--db-name="${DB_NAME}" \
--db-user="${DB_USER}" \
--db-password="${DB_PW}" \
--use-rewrites=1 \
--use-secure=0 \
--base-url="http://${DOMAIN_URL}" \
--base-url-secure="https://${DOMAIN_URL}" \
--admin-user="${MAGENTO_ADMIN_USER}" \
--admin-password="${MAGENTO_ADMIN_PW}" \
--admin-email="${MAGENTO_ADMIN_EMAIL}" \
--admin-firstname="${MAGENTO_ADMIN_FIRSTNAME}" \
--admin-lastname="${MAGENTO_ADMIN_LASTNAME}" \
--session-save="db"

/var/www/magento2/bin/magento setup:di:compile

chown -R www-data:www-data /var/www/magento2

echo "install finish!!"
