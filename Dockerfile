FROM debian:stretch

RUN apt-get -yq update && apt-get -yq upgrade && apt-get -y install apache2 \
	openssl git curl sudo mysql-client wget \
	ca-certificates apt-transport-https gnupg \
	&& apt-get -y autoremove && apt-get clean

RUN wget -q https://packages.sury.org/php/apt.gpg -O- | sudo apt-key add -

RUN echo "deb https://packages.sury.org/php/ stretch main" | sudo tee /etc/apt/sources.list.d/php.list

RUN apt-get -yq update && apt-get -y install \
	php7.1 php7.1-common php7.1-curl php7.1-mbstring php7.1-gd php7.1-mcrypt php7.1-json php7.1-cli  php7.1-redis php7.1-memcached \
	php7.1-mysql php7.1-imagick php7.1-intl php7.1-xsl libapache2-mod-php7.1

COPY docker/apache.conf /etc/apache2/sites-available/site.conf

RUN openssl genrsa -out /etc/ssl/private/apache.key 2048 && openssl req -new -x509 -key /etc/ssl/private/apache.key -days 365 -sha256 -out /etc/ssl/certs/apache.crt \
    -subj "/C=DE/ST=SA/L=local/O=local/CN=localhost"

RUN a2enmod rewrite && a2enmod deflate && a2enmod php7.1 && a2enmod expires && a2ensite site && a2dissite 000-default && a2enmod ssl

ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/run/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2/run.pid
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

EXPOSE 80
EXPOSE 443

CMD ["apache2", "-DFOREGROUND"]