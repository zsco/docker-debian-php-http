FROM debian:stretch

RUN apt-get -yq update && apt-get -yq upgrade && apt-get -y install apache2 \
	php php-gd php-mcrypt php-json php-cli php-mysql php-curl php-imagick php-intl php-redis php-memcached \
	php-xsl libapache2-mod-php \
	openssl git curl sudo mysql-client cron \
	&& apt-get -y autoremove && apt-get clean

COPY docker/apache.conf /etc/apache2/sites-available/site.conf

RUN openssl genrsa -out /etc/ssl/private/apache.key 2048 && openssl req -new -x509 -key /etc/ssl/private/apache.key -days 365 -sha256 -out /etc/ssl/certs/apache.crt \
    -subj "/C=DE/ST=SA/L=local/O=local/CN=localhost"

RUN a2enmod rewrite && a2enmod deflate && a2enmod php7.0 && a2enmod expires && a2ensite site && a2dissite 000-default && a2enmod ssl

ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/run/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2/run.pid
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

EXPOSE 80
EXPOSE 443

CMD ["apache2", "-DFOREGROUND"]