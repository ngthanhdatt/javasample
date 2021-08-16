#!/bin/bash
TIME_NOW=`date +%Y/%m/%d-%H:%M:%S`
BUILD_DATE=`date +%Y_%m_%d`
BUILD_TAG=`date +%Y%m%d_%H%M%S`

SOURCE="/var/lib/jenkins/workspace/sample-war"
BUILD_DIR="/opt/centos7tomcat"
LOGS="/var/lib/jenkins/workspace/sample-war/logs/sample_${BUILD_DATE}.log"
IMAGE="centos7tomcat"

echo "=== Remove old code in build folder ${BUILD_DIR}"
rm -rf ${BUILD_DIR}/apache-tomcat-9.0.50/webapps/*

echo "=== Copy code to build folder ${BUILD_DIR}"
cp ${SOURCE}/sample.war ${BUILD_DIR}/apache-tomcat-9.0.50/webapps/

echo "=== Prepare code to build"

echo "=== Build image"
cd ${BUILD_DIR}
docker build -t ${IMAGE} .

echo "=== Push image to registry server"
BUILD_TAG=`date +%Y%m%d_%H%M%S`
docker tag ${IMAGE}:latest ngthanhdat/${IMAGE}:${BUILD_TAG}
docker push ngthanhdat/${IMAGE}:${BUILD_TAG}

echo "=================================================================" >> ${LOGS}
TIME_NOW=`date +%Y/%m/%d-%H:%M:%S`
echo "${TIME_NOW} Finish build and push image to registry server" >> ${LOGS}
echo "Image name: ${IMAGE}" >> ${LOGS}
echo "Build tag: ${BUILD_TAG}" >> ${LOGS}

echo "=== ${TIME_NOW} Finish build and push image to registry server"
echo "=== Image name: ${IMAGE}"
echo "=== Build tag: ${BUILD_TAG}"

echo "=== Update and run new image"

ids=$(docker ps -a -q)
for id in $ids
do
  echo "$id"
  docker stop $id 
done

#đoạn này chạy lệnh run -dp 
docker run -it -dp 443:443 ngthanhdat/${IMAGE}:${BUILD_TAG}

echo "=== Finish run new image"

exit 0
