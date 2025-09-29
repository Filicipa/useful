# Don't run production as root
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nestjs
USER nestjs

##################

RUN groupadd -r myuser && useradd -r -g myuser myuser
#    <HERE DO WHAT YOU HAVE TO DO AS A ROOT USER LIKE INSTALLING PACKAGES ETC.>
USER myuser

####
RUN useradd -G www-data,root -u 1000 -d /home/<user_name> <user_name>
RUN mkdir -p /home/<user_name>/.composer && \
    chown -R <user_name>:<user_name> /home/<user_name> && \
    chown -R <user_name>:<user_name> /usr/src