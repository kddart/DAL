#!/bin/bash

echo "Installing monetdb...";
cd /usr/local;
curl --insecure -L https://www.monetdb.org/downloads/sources/archive/MonetDB-11.35.9.tar.bz2 | tar jx;
cd /usr/local/MonetDB-11.35.9 && ./configure;
make;
make install;

echo "Installing monetdb driver for perl's DBI...";
cd /usr/local;
curl --insecure -L https://github.com/MonetDB/monetdb-perl/archive/v1.1-1.tar.gz | tar zx;
cd /usr/local/monetdb-perl-1.1-1;
make;
make install;

rm -rf /usr/local/MonetDB-11.35.9;
rm -rf /usr/local/monetdb-perl-1.1-1;

echo "Configuring monetdb...";

ldconfig;

mkdir /var/lib/monetdb;
mkdir /var/lib/monetdb/dbfarm;
monetdbd create /var/lib/monetdb/dbfarm;

CONFIG="[Unit]
Description=MonetDB daemon
After=mysql.service
[Service]
User=root
Type=forking
ExecStart=/usr/local/bin/monetdbd start /var/lib/monetdb/dbfarm
ExecStop=/usr/local/bin/monetdbd stop /var/lib/monetdb/dbfarm
[Install]
WantedBy=multi-user.target";

echo "$CONFIG" > /etc/systemd/system/monetdbd.service;
systemctl --system daemon-reload;
systemctl enable monetdbd.service;