FROM nginxinc/nginx-unprivileged:perl

RUN rm /etc/nginx/conf.d/default.conf

COPY default.conf /etc/nginx/conf.d/default.conf

#RUN chown -R nginx:nginx /var/cache/nginx &&\
#	chown -R nginx:nginx /var/log/nginx &&\
#    chown -R nginx:nginx /etc/nginx/conf.d

#RUN touch /var/run/nginx.pid && \
#    chown -R nginx:nginx /var/run/nginx.pid

RUN mkdir /tmp/html

COPY index.html /tmp/html

RUN mkdir /tmp/html/repecdata

RUN mkdir -p /repec_files/repeclogs/

COPY dspace2redif* /repec_files/

COPY ferarch.rdf /tmp/html/repecdata/

COPY ferseri.rdf /tmp/html/repecdata/

RUN chown -R nginx:nginx /repec_files

RUN export DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -yq install make && apt-get -yq install build-essential && apt-get -yq install cron && apt-get -yq install moreutils

RUN perl -MCPAN -e'install "LWP::Simple"'

RUN apt-get -yq install liblwp-protocol-https-perl

RUN cpan install LWP::Protocol::https

COPY --chown=nginx repec-cron /etc/cron.d/repec-cron

RUN chmod 0644 /etc/cron.d/repec-cron

RUN crontab -u nginx /etc/cron.d/repec-cron && chmod u+s /usr/sbin/cron

RUN touch /var/log/cron.log

RUN chown -R nginx:nginx /var/log/cron.log

EXPOSE 8080

USER nginx

RUN cd /repec_files/; ./dspace2redif.pl; ./dspace2redif_1.pl; ./dspace2redif_2.pl

CMD cd /repec_files/; ./dspace2redif.pl; ./dspace2redif_1.pl; ./dspace2redif_2.pl; /usr/sbin/cron; nginx -g 'daemon off;'
