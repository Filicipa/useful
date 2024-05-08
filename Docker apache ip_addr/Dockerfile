FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive 
RUN apt -y update && \
    apt -y install apache2 && \
    apt -y install php && \
    echo "ServerName localhost" >> /etc/apache2/apache2.conf

COPY ./index.php /var/www/html/index.html

CMD ["/usr/sbin/apache2ctl","-D","FOREGROUND"]

EXPOSE 80