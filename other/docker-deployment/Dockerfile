FROM opensuse/leap:15.4

# Update the system and install systemd
RUN zypper --non-interactive update \
 && zypper --non-interactive install -y systemd

# Enable systemd
ENV INITSYSTEM on

# Install sshd
RUN zypper --non-interactive update && \
    zypper --non-interactive install openssh && \
    echo "root:opensuse" | chpasswd

# Enable sshd
RUN systemctl enable sshd.service

ARG WORKDIR

WORKDIR $WORKDIR

COPY ./1-binaries.sh ./

RUN chmod +x ./1-binaries.sh \
    && ./1-binaries.sh

COPY ./2-perllibs.sh ./

RUN chmod +x ./2-perllibs.sh \
    && ./2-perllibs.sh

COPY ./3-db-monetdb.sh ./

RUN chmod +x ./3-db-monetdb.sh \
    && ./3-db-monetdb.sh

COPY ./4-db-solr.sh ./

RUN chmod +x ./4-db-solr.sh \
    && ./4-db-solr.sh

COPY ./5-db-postgresql.sh ./

RUN chmod +x ./5-db-postgresql.sh \
    && ./5-db-postgresql.sh

COPY ./6-db-mariadb.sh ./

RUN chmod +x ./6-db-mariadb.sh \
    && ./6-db-mariadb.sh

COPY ./7-apache.sh ./

RUN chmod +x ./7-apache.sh \
    && ./7-apache.sh

# Clean up zypper cache and temporary files
RUN zypper clean -a && \
    rm -rf /tmp/* /var/tmp/*

# Allow SSH
EXPOSE 22
EXPOSE 80
EXPOSE 8983

CMD ["/usr/lib/systemd/systemd"]
