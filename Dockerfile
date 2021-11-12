FROM php:8.0-fpm-alpine

ARG UID=1000
ARG GID=1000
WORKDIR /var/www/html

# install extentions
RUN docker-php-ext-install pdo_mysql

# install supervisor shadow nginx
RUN apk add --no-cache supervisor shadow nginx
RUN groupmod -g $GID www-data
RUN usermod -u $UID www-data

# copy configs
COPY --chown=www-data:www-data ./docker/supervisor /etc/supervisor
COPY --chown=www-data:www-data docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY --chown=www-data:www-data docker/nginx/nginx-site.conf /etc/nginx/conf.d/default.conf
COPY --chown=www-data:www-data ./docker/php/php.ini /usr/local/etc/php/php.ini
COPY --chown=www-data:www-data ./docker/php/www.conf /usr/local/etc/php-fpm.d/www.conf

# make directories
RUN mkdir -p /var/log/php-fpm /var/log/nginx /var/log/cronjob
RUN chown www-data:www-data -R /var/lib/nginx /var/log/nginx /var/log/php-fpm /var/log/cronjob

# cronjobs 
COPY ./docker/cronjobs /cronjobs
RUN /usr/bin/crontab -u www-data /cronjobs
# all project
COPY --chown=www-data:www-data ./src $PWD

USER www-data