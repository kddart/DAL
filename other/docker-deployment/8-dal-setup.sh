#!/bin/bash

DAL_TAR_FILE=$1
DAL_ADDRESS_NAME=$2
MONETDB_PASSWORD=$3
MYSQL_PASSWORD=$4
POSTGRESLQ_PASSWORD=$5

DAL_VERSION="v2.7.0"
DAL_DB_VERSION="v2_7_0"
DAL_REPO_PATH="/root/deployment/dal_$DAL_VERSION"
APACHE_BASE_PATH="/srv/www"

if [ ! -f $DAL_TAR_FILE ]; then
    echo "DAL's tar file was not found."
    exit 1
fi

mkdir $DAL_REPO_PATH && tar -xzf $DAL_TAR_FILE -C $DAL_REPO_PATH

while ! (systemctl is-active postgresql.service && systemctl is-active mysql.service)  >/dev/null 2>&1; do
    # SYSTEMD starts services asynchronously
    # Need to make sure all dependent services are started before setting up DAL
    sleep 1
done


echo "Setting up DAL..."


echo "[TASK]Configure PostgreSQL access permission settings"
echo 'local   all             all                                   trust' > /var/lib/pgsql/data/pg_hba.conf
echo 'host    all             all             127.0.0.1/32          trust' >> /var/lib/pgsql/data/pg_hba.conf
echo 'host    all             all             ::1/128               trust' >> /var/lib/pgsql/data/pg_hba.conf
# echo "host    kddart_gis_enviro_$DAL_DB_VERSION  all           $IP_NETWORK             password" >> /var/lib/pgsql/data/pg_hba.conf
echo "host    kddart_gis_enviro_$DAL_DB_VERSION  all           127.0.0.1/24            password" >> /var/lib/pgsql/data/pg_hba.conf
systemctl restart postgresql



echo "[TASK]Create KDDart Databases"
/usr/local/bin/monetdbd start /var/lib/monetdb/dbfarm
sed -i "s|DB_PASS='yourSecurePassword'|DB_PASS='$MYSQL_PASSWORD'|g" $DAL_REPO_PATH/other/create_dbs.sh;
$DAL_REPO_PATH/other/create_dbs.sh 1 \
                                   kddart_gis_enviro_$DAL_DB_VERSION \
                                   $DAL_REPO_PATH/other/db_files/kddart_gis_enviro_dal_$DAL_VERSION\_postgis2.sql \
                                   kddart_$DAL_DB_VERSION \
                                   $DAL_REPO_PATH/other/db_files/kddart_dal_$DAL_VERSION.sql \
                                   kddart_marker_$DAL_DB_VERSION \
                                   $DAL_REPO_PATH/other/db_files/kddart_marker_dal_$DAL_VERSION.sql \
                                   1



echo "[TASK]Make host entry"
echo ""
MYIP=$(hostname -i)
echo "$MYIP $DAL_ADDRESS_NAME" >> /etc/hosts




echo "[TASK]Copy apache configuration"
cp $DAL_REPO_PATH/other/http-kddart.example.com.conf /etc/apache2/vhosts.d/http-$DAL_ADDRESS_NAME.conf



echo "[TASK]Configure apache vhost file"
sed -i "s/kddart.example.com/$DAL_ADDRESS_NAME/g" /etc/apache2/vhosts.d/http-$DAL_ADDRESS_NAME.conf



echo "[TASK]Craete directories"
PATHS=(
    "$APACHE_BASE_PATH/cgi-bin/kddart"
    "$APACHE_BASE_PATH/tmp"
    "$APACHE_BASE_PATH/tmp/kddart"
    "$APACHE_BASE_PATH/perl-lib"
    "$APACHE_BASE_PATH/vhosts"
    "$APACHE_BASE_PATH/vhosts/$DAL_ADDRESS_NAME"
    "$APACHE_BASE_PATH/vhosts/$DAL_ADDRESS_NAME/storage"
    "$APACHE_BASE_PATH/vhosts/$DAL_ADDRESS_NAME/storage/multimedia"
    "$APACHE_BASE_PATH/session"
    "$APACHE_BASE_PATH/session/kddart"
    "$APACHE_BASE_PATH/secure"
)
for path in "${PATHS[@]}"
do
    mkdir -p $path
    chown wwwrun:www $path
    chmod 0755 $path
done



echo "[TASK]Create password files"
FILE_PASSWORD_MONETDB="$APACHE_BASE_PATH/secure/monetdb_user.txt"
FILE_PASSWORD_MYSQL="$APACHE_BASE_PATH/secure/mysql_user.txt"
FILE_PASSWORD_POSTGRESQL="$APACHE_BASE_PATH/secure/postgres_user.txt"
echo "username=monetdb" > $FILE_PASSWORD_MONETDB && echo "password=$MONETDB_PASSWORD" >> $FILE_PASSWORD_MONETDB
echo "username=kddart_dal" > $FILE_PASSWORD_MYSQL && echo "password=$MYSQL_PASSWORD" >> $FILE_PASSWORD_MYSQL
echo "username=kddart_dal" > $FILE_PASSWORD_POSTGRESQL && echo "password=$POSTGRESLQ_PASSWORD" >> $FILE_PASSWORD_POSTGRESQL



echo "[TASK]Copy DAL relevant files"
cp -rp $DAL_REPO_PATH/vhosts/kddart.example.com/* $APACHE_BASE_PATH/vhosts/$DAL_ADDRESS_NAME
cp -rp $DAL_REPO_PATH/perl-lib/* $APACHE_BASE_PATH/perl-lib
cp $DAL_REPO_PATH/other/kddart_dal.cfg $APACHE_BASE_PATH/secure
cp $DAL_REPO_PATH/cgi-bin/kddart/* $APACHE_BASE_PATH/cgi-bin/kddart
chown wwwrun:www $APACHE_BASE_PATH/vhosts/$DAL_ADDRESS_NAME -Rf
chown wwwrun:www $APACHE_BASE_PATH/secure/kddart_dal.cfg



echo "[TASK]Change /tmp/kddart to $APACHE_BASE_PATH/tmp/kddart (Apache2.4 cannot write to /tmp)"
sed -i "s|/tmp/kddart/|$APACHE_BASE_PATH/tmp/kddart/|" $APACHE_BASE_PATH/secure/kddart_dal.cfg



echo "[TASK]Update kddart_dal.cfg file"
sed -i "s/kddart.example.com/$DAL_ADDRESS_NAME/g" $APACHE_BASE_PATH/secure/kddart_dal.cfg



echo "[TASK]Add perl module load to sysconfig"
a2enmod perl
echo "[TASK]Add headers module load to sysconfig"
a2enmod headers


echo "[Task]Change ACL for tmp directory"
setfacl -d -m o::rx $APACHE_BASE_PATH/tmp/kddart;   # sets default ACLs by granting read and execute permissions to the "other" class 
setfacl -d -m g::rwx $APACHE_BASE_PATH/tmp/kddart;  # sets default ACLs by granting read, write, and execute permissions to the group that owns the directory.


systemctl restart apache2;
systemctl restart mysql;
systemctl restart postgresql;