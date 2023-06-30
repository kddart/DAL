#!/bin/bash

echo "Installing supporting binaries..."
echo "Adding zypper repo 'Geo'..."
zypper ar --no-gpgcheck https://download.opensuse.org/repositories/Application:/Geo/15.4 Geo

echo "Adding zypper repo 'Perl-Dev'..."
zypper ar --no-gpgcheck https://download.opensuse.org/repositories/devel:/languages:/perl/15.4 Perl-Dev

BINARIES=(
    'libopenssl-devel'
    'tar'
    'gzip'
    'git'
    'make'
    'bison'
    'gcc'
    'perl'
    'curl'
    'apache2'
    'apache2-mod_perl'
    'perl-App-cpanminus'
    'mariadb'
    'libmariadb-devel'
    'perl-DBD-Pg'
    'perl-DBD-mysql'
    'perl-Archive-Zip'
    'perl-Net-SSLeay'
    'perl-IO-Socket-SSL'
    'perl-XML-DOM'
    'perl-XML-Parser'
    'perl-XML-LibXML'
    'perl-Math-Pari'
    'perl-Crypt-Random'
    'libpq5'
    'postgresql15'
    'postgresql15-server'
    'postgresql15-contrib'
    'postgresql15-postgis'
    'shapelib'
    'libshp-devel'
    'pcre'
    'pcre-devel'
    'libxml2'
    'libxml2-devel'
    'java-1_8_0-openjdk'
    'pcre-devel'
    'libxml2-devel'
    'acl'
    'lsof'
    'cron'
    'vim'
    'bzip2'
    'perl-LWP-Protocol-https'
    'sysvinit-tools'
    'insserv'
)
concat=""
for s in "${BINARIES[@]}"
do
    concat="$concat $s"
done
echo "zypper --no-gpg-checks --non-interactive install $concat"
zypper --no-gpg-checks --non-interactive install $concat