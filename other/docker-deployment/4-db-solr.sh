#!/bin/bash

SOLR_VERSION="8.11.1"
SOLR_INSTALL_DIR="/opt"
SOLR_HOME="/var/solr"
SOLR_TMP_DIR="/root/tmp_install_solr"
SOLR_CONFIG="/etc/default/solr.in.sh"

echo "export JAVA_HOME=/usr/lib64/jvm/java-1.8.0-openjdk-1.8.0/jre" >> /etc/bash.bashrc;
export JAVA_HOME=/usr/lib64/jvm/java-1.8.0-openjdk-1.8.0/jre;

echo "export CLASSPATH=$JAVA_HOME/lib" >> /etc/bash.bashrc;
export CLASSPATH=$JAVA_HOME/lib;

echo "Installing Solr-$SOLR_VERSION...";
mkdir $SOLR_TMP_DIR;
cd $SOLR_TMP_DIR;
curl -O http://archive.apache.org/dist/lucene/solr/$SOLR_VERSION/solr-$SOLR_VERSION.tgz && tar -xzf solr-$SOLR_VERSION.tgz;
./solr-$SOLR_VERSION/bin/install_solr_service.sh $SOLR_TMP_DIR/solr-$SOLR_VERSION.tgz -i $SOLR_INSTALL_DIR -d $SOLR_HOME -f;

chown solr:root -R /var/solr;

SOLR_SERVICE=""