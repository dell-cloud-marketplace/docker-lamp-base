FROM ubuntu:trusty
MAINTAINER Dell Cloud Market Place <Cloud_Marketplace@dell.com>

# Install packages
RUN apt-get update 
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install supervisor 
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install git 
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install apache2=2.4.7-1ubuntu4.1
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install libapache2-mod-php5
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server=5.5.40-0ubuntu0.14.04.1
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php5-mysql=5.5.9+dfsg-1ubuntu4.4
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install pwgen 
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php-apc=4.0.2-2build1
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install openssl

# Add image configuration and scripts
ADD start-apache2.sh /start-apache2.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
RUN chmod 755 /*.sh

# Config to enable .htaccess
ADD apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Environment variables to configure PHP
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Configure SSL
RUN a2enmod ssl
RUN mkdir /etc/apache2/ssl 
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout \
    /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt \
    -subj '/O=Dell/OU=MarketPlace/CN=www.dell.com'
RUN a2ensite default-ssl
RUN service apache2 restart

EXPOSE 80 3306 443

CMD ["/run.sh"]

