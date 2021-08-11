#!/bin/bash
TIME_NOW=`date +%Y/%m/%d-%H:%M:%S`
BUILD_DATE=`date +%Y_%m_%d`
BUILD_TAG=`date +%Y%m%d_%H%M%S`

SOURCE="/home/jenkin/.jenkins/workspace/PRODUCT_VNPTID_DANGKY_Build_Image"
BUILD_DIR="/opt/build_image_jenkin/IDP/PRODUCT/VNPTID/vnptid-register"
LOGS="/home/jenkin/.deploy/IDP/PRODUCT/VNPTID/dangky/logs/dangky_${BUILD_DATE}.log"
IMAGE="vnptid-dangky"

echo "=== Remove old code in build folder ${BUILD_DIR}"
rm -rf ${BUILD_DIR}/apache-tomcat-9.0.24/webapps/ROOT.war

echo "=== Copy code to build folder ${BUILD_DIR}"
cp ${SOURCE}/ROOT.war ${BUILD_DIR}/apache-tomcat-9.0.24/webapps/

echo "=== Prepare code to build"

echo "=== Build image"
cd ${BUILD_DIR}
docker build -t ${IMAGE} .

echo "=== Push image to registry server"
BUILD_TAG=`date +%Y%m%d_%H%M%S`
docker tag ${IMAGE}:latest crelease.devops.vnpt.vn:10103/${IMAGE}:${BUILD_TAG}
docker push crelease.devops.vnpt.vn:10103/${IMAGE}:${BUILD_TAG}

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
  docker stop $id && docker rm $id
done

#đoạn này chạy lệnh run -dp 

echo "=== Finish run new image"

exit 0
