#!/usr/bin/env bash
PROJECT="guifi"
PASSWD="1234567890"
DRUPAL="drupal-6.37"
MYSQL_DB="guifi_dev"
MYSQL_USER="guifi"
MYSQL_PASSWD="guifinet"
API_SECRET="ThisTokenIsNotSoSecretChangeIt"

# update / upgrade
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

# install apache 2.5 and php 5.5
sudo apt-get install -y apache2
sudo apt-get install -y php5

# install mysql and give password to installer
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $PASSWD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $PASSWD"
sudo apt-get -y install mysql-server
sudo apt-get install php5-mysql

sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PASSWD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $PASSWD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PASSWD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
sudo apt-get -y install phpmyadmin

sudo apt-get -y install libapache2-mod-php5 php5-gd

# setup hosts file
VHOST=$(cat <<EOF
<VirtualHost *:80>
    DocumentRoot "/var/www/html/${PROJECT}"
    <Directory "/var/www/html/${PROJECT}">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
)
sudo su -c "echo \"${VHOST}\" > /etc/apache2/sites-available/000-default.conf"

# enable mod_rewrite
sudo a2enmod rewrite

# change user
sudo sed -i 's/www-data/vagrant/' /etc/apache2/envvars

# restart apache
sudo service apache2 restart

# install git
sudo apt-get -y install git

# directory zip
sudo mkdir -p /var/www/zip

# install drupal
sudo mkdir -p /var/www/html/
cd /var/www/html/
sudo wget -q http://ftp.drupal.org/files/projects/$DRUPAL.tar.gz
sudo tar zxf $DRUPAL.tar.gz
sudo mv $DRUPAL.tar.gz ../zip/

# Link symbolic
sudo ln -s /var/www/html/$DRUPAL /var/www/html/${PROJECT}

# Instal·lar moduls
cd $DRUPAL/sites/all/modules/
MODULS_LIST="webform-6.x-3.23 views-6.x-2.18 views_slideshow-6.x-2.4 i18n-6.x-1.10 schema-6.x-1.7 devel-6.x-1.28 potx-6.x-3.3 l10n_client-6.x-2.2 languageicons-6.x-2.1 language_sections-6.x-2.5 diff-6.x-2.3 captcha-6.x-2.7 captcha_pack-6.x-1.0-beta3 event-6.x-2.x-dev cck-6.x-2.10 fckeditor-6.x-2.4 image-6.x-1.2 image_filter-6.x-1.0 fivestar-6.x-1.21 votingapi-6.x-2.3"
for module in $MODULS_LIST
do
  sudo wget -q http://ftp.drupal.org/files/projects/${module}.tar.gz
  sudo tar zxf ${module}.tar.gz
  sudo mv ${module}.tar.gz ../../../../../zip/
done

# BD
cd /var/www/html/
sudo wget -q http://www.guifi.net/guifi66_devel.sql.gz
echo "create database ${MYSQL_DB};" | mysql -u root -p${PASSWD}
echo "grant all on ${MYSQL_DB}.* to ${MYSQL_USER}@localhost identified by '${MYSQL_PASSWD}';" | mysql -u root -p${PASSWD}

sudo gunzip guifi66_devel.sql.gz
mysql -u root -p${PASSWD} ${MYSQL_DB} < guifi66_devel.sql
rm guifi66_devel.sql

sudo mkdir $DRUPAL/{files,files/nanostation,tmp}
sudo chmod 777 $DRUPAL/{files,files/nanostation,tmp}

# chown vagrant
sudo chown -R vagrant:vagrant /var/www

# settings.php
cd /var/www/html/$DRUPAL/sites/default/
sudo cp default.settings.php settings.php
sudo sed -i "s|mysql://username:password@localhost/databasename|mysql://${MYSQL_USER}:${MYSQL_PASSWD}@localhost/${MYSQL_DB}|" settings.php

# install php5 intl
sudo apt-get -y install php5-intl

# PHP timezone
PHPTIMEZONE=$(cat <<EOF
date.timezone = "Europe/Madrid"
EOF
)
sudo su -c "echo \"${PHPTIMEZONE}\" > /etc/php5/cli/conf.d/timezone.ini"
sudo su -c "echo \"${PHPTIMEZONE}\" > /etc/php5/apache2/conf.d/timezone.ini"

# guifi-api configuration
cd /var/www/html/guifi-api/
PARAMETERS=$(cat <<EOF
parameters:
    database_host: 127.0.0.1
    database_port: null
    database_name: ${MYSQL_DB}
    database_user: ${MYSQL_USER}
    database_password: ${MYSQL_PASSWD}
    mailer_transport: smtp
    mailer_host: 127.0.0.1
    mailer_user: null
    mailer_password: null
    secret: ${API_SECRET}
EOF
)
echo "${PARAMETERS}" > app/config/parameters.yml

# Install guifi-api dependencies
php composer.phar install


# Publish guifi-api on /api
APACHE_API_CONF=$(cat > /etc/apache2/conf-available/guifi-api.conf <<EOF
Alias /api /var/www/html/guifi-api/web

<Directory /var/www/html/guifi-api/web>
    AllowOverride All
    Order Allow,Deny
    Allow from All
</Directory>
EOF
)
sudo su -c "echo \"${APACHE_API_CONF}\" > /etc/apache2/conf-available/guifi-api.conf"
sudo a2enconf guifi-api
sudo service apache2 reload
