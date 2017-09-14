FROM ubuntu:16.04
MAINTAINER "@ebarault"

RUN apt-get -y update && \
  apt-get -y install git curl postgresql-client build-essential libssl-dev libpq-dev openssl

# RUN curl -o proftpd.tar.gz ftp://ftp.proftpd.org/distrib/source/proftpd-1.3.6rc4.tar.gz && \
#   tar zxvf proftpd.tar.gz

# RUN cd proftpd-1.3.6rc4 && \

RUN git clone https://github.com/proftpd/proftpd.git

RUN cd proftpd && \
  ./configure --sysconfdir=/etc/proftpd --localstatedir=/var/proftpd --with-modules=mod_sql:mod_sql_postgres:mod_sql_passwd:mod_tls --enable-openssl --disable-ident && \
  make && \
  make install

RUN groupadd proftpd && \
  useradd -g proftpd proftpd

# CONF FILES
COPY proftpd.conf /etc/proftpd/proftpd.conf
COPY tls.conf /etc/proftpd/tls.conf
COPY sql.conf /etc/proftpd/sql.conf

COPY entrypoint.sh ./entrypoint.sh
RUN chmod a+x ./entrypoint.sh

# PROFTPD LOGS
VOLUME /var/log/proftpd

# FTP ROOT
VOLUME /srv/ftp

# SSL CERTS
VOLUME /etc/proftpd/ssl

# SQL PASSWORD SALT
VOLUME /etc/proftpd/salt

# MOD EXEC CONF
VOLUME /etc/proftpd/exec

EXPOSE 21 49152-49407

ENTRYPOINT ["./entrypoint.sh"]
