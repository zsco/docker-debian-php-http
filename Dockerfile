FROM debian:jessie

RUN apt-get -yq update && apt-get -yq upgrade && apt-get -y install apache2 \
	php5 php5-gd php5-mcrypt php5-json php5-cli php5-mysql php5-curl php5-imagick php5-intl php5-redis php5-memcached \
	php5-xsl libapache2-mod-php5 \
	openssl git curl sudo mysql-client cron \
	&& apt-get -y autoremove && apt-get clean

COPY docker/apache.conf /etc/apache2/sites-available/site.conf

ADD docker/crontab /etc/cron.d/magento-cron

RUN chmod 0644 /etc/cron.d/magento-cron

RUN touch /var/log/cron.log

RUN openssl genrsa -out /etc/ssl/private/apache.key 2048 && openssl req -new -x509 -key /etc/ssl/private/apache.key -days 365 -sha256 -out /etc/ssl/certs/apache.crt \
    -subj "/C=DE/ST=SA/L=local/O=local/CN=localhost"

RUN a2enmod rewrite && a2enmod deflate && a2enmod php5 && a2enmod expires && a2ensite site && a2dissite 000-default && a2enmod ssl

ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/run/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2/run.pid
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

EXPOSE 80
EXPOSE 443

CMD ["apache2", "-DFOREGROUND"]