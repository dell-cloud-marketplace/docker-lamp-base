FROM ubuntu:trusty
MAINTAINER Dell Cloud Market Place <Cloud_Marketplace@dell.com>

# Update existing packages.
RUN apt-get update 

# Ensure UTF-8
RUN locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    export LC_ALL=en_US.UTF-8 && \
    export LANGUAGE=en_US.UTF-8 && \
    export LANG=en_US.UTF-8

# Install packages
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get -y install \
        supervisor \
        git \
        apache2 \
        libapache2-mod-php5 \
        mysql-server-5.5 \
        php5-mysql \
        pwgen \
        php-apc \
        openssl
RUN apt-get -y clean

# Add image configuration and scripts
COPY start-apache2.sh /start-apache2.sh
COPY start-mysqld.sh /start-mysqld.sh
COPY run.sh /run.sh
RUN chmod 755 /*.sh
COPY my.cnf /etc/mysql/conf.d/my.cnf
COPY supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
COPY supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
COPY create_mysql_admin_user.sh /create_mysql_admin_user.sh
RUN chmod 755 /*.sh

# Config to enable .htaccess
COPY apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Environment variables
ENV MYSQL_PASS ""
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Configure SSL
RUN a2enmod ssl
RUN mkdir /etc/apache2/ssl 
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout \
    /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt \
    -subj '/O=Dell/OU=MarketPlace/CN=www.dell.com'
RUN a2ensite default-ssl

EXPOSE 80 3306 443

CMD ["/run.sh"]

