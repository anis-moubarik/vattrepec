FROM nginx:stable-perl

COPY index.html /usr/share/nginx/html

RUN mkdir /usr/share/nginx/html/repecdata

RUN mkdir -p /repec_files/repeclogs/

COPY dspace2redif* /repec_files/

COPY ferarch.rdf /usr/share/nginx/html/repecdata/

COPY ferseri.rdf /usr/share/nginx/html/repecdata/

RUN rm /etc/nginx/conf.d/default.conf

COPY default.conf /etc/nginx/conf.d/default.conf

RUN export DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -yq install make && apt-get -yq install build-essential && apt-get -yq install cron && apt-get -yq install moreutils

RUN perl -MCPAN -e'install "LWP::Simple"'

RUN apt-get -yq install liblwp-protocol-https-perl

RUN cpan install LWP::Protocol::https

COPY repec-cron /etc/cron.d/repec-cron

RUN chmod 0644 /etc/cron.d/repec-cron

RUN crontab /etc/cron.d/repec-cron

RUN touch /var/log/cron.log

RUN cd /repec_files/; ./dspace2redif.pl 2>&1 | ts >> /repec_files/repeclogs/repec.log; ./dspace2redif_1.pl 2>&1 | ts >> /repec_files/repeclogs/repec.log; ./dspace2redif_2.pl 2>&1 | ts >> /repec_files/repeclogs/repec.log

CMD /usr/sbin/cron; nginx -g 'daemon off;'