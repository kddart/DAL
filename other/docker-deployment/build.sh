#!/bin/bash

DAL_TAR_FILE=$1
DAL_ADDRESS_NAME=$2
MONETDB_PASSWORD=$3
MYSQL_PASSWORD=$4
POSTGRESLQ_PASSWORD=$5

IMAGENAME="dal_v2_7_0"
WORKDIR="/root/deployment"

# Stop and remove all containers using dal image
docker ps -a -q --filter ancestor=$IMAGENAME | xargs docker stop | xargs docker rm

# Build the image
docker build --build-arg WORKDIR=$WORKDIR -t $IMAGENAME .

# Start a container using that image
C_ID=$(docker run --privileged -d -it -p 2222:22 -p 80:80 -p 8983:8983 -v /root/dal:/root/dal_v2_7_0 $IMAGENAME)

# Copy setup script to container
docker cp ./8-dal-setup.sh $C_ID:$WORKDIR/8-dal-setup.sh

# Copy dal's tar file to container
docker cp $DAL_TAR_FILE $C_ID:$WORKDIR/dal.tar.gz

# Run the setup script
docker exec $C_ID /bin/bash $WORKDIR/8-dal-setup.sh $WORKDIR/dal.tar.gz $DAL_ADDRESS_NAME $MONETDB_PASSWORD $MYSQL_PASSWORD $POSTGRESLQ_PASSWORD

docker exec -ti $C_ID bash
