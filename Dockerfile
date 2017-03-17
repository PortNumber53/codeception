FROM php:7.1.2-cli

MAINTAINER Me Grimlock <grimlock@portnumber53.com>

# Install required system packages
RUN apt-get update && \
    apt-get -y install \
            git \
            libmcrypt-dev \
            zlib1g-dev \
            libssl-dev \
            python \
            python-pip \
        --no-install-recommends && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# AWS cls
RUN pip install awscli

# Install php extensions
RUN docker-php-ext-install \
    bcmath \
    mcrypt \
    zip

# Install pecl extensions
RUN pecl install xdebug && \
    # docker-php-ext-enable mongodb && \
    docker-php-ext-enable xdebug
# mongodb 

# Configure php
RUN echo "date.timezone = UTC" >> /usr/local/etc/php/php.ini

# Install composer
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN curl -sS https://getcomposer.org/installer | php -- \
        --filename=composer \
        --install-dir=/usr/local/bin
RUN composer global require --optimize-autoloader \
        "hirak/prestissimo"

# Install Codeception
RUN curl -o codecept.phar http://codeception.com/codecept.phar \
    && chmod +x codecept.phar \
    && mv codecept.phar /usr/local/bin/codecept

# Prepare application
#WORKDIR /repo

# Install vendor
#COPY ./composer.json /repo/composer.json
#RUN composer install --prefer-dist --optimize-autoloader

# Add source-code
#COPY . /repo

#ENV PATH /repo:${PATH}
ENTRYPOINT ["codecept"]

# Prepare host-volume working directory
RUN mkdir /var/www
WORKDIR /var/www