#!/bin/bash

SPARK_VERSIONS="2.1.0-2.2.1-1-hadoop-2.6 2.1.0-2.2.1-1-hadoop-2.7"
ZEPPELIN_VERSION=0.7.3
DOCKER_REPO=${DOCKER_REPO:-maibornwolff}
MINOR_VERSION=1

cd docker
for version in $SPARK_VERSIONS; do
  for package in all netinst; do
    echo "Building zeppelin:$ZEPPELIN_VERSION-$version-$package"
    docker build -t zeppelin:$ZEPPELIN_VERSION-$version-$package-$MINOR_VERSION --build-arg SPARK_VERSION=$version --build-arg ZEPPELIN_VERSION=$ZEPPELIN_VERSION --build-arg PACKAGE_TYPE=$package .
    if [ ${PUSH:-"0"} == "1" ]; then
      docker tag zeppelin:$ZEPPELIN_VERSION-$version-$package-$MINOR_VERSION $DOCKER_REPO/zeppelin:$ZEPPELIN_VERSION-$version-$package-$MINOR_VERSION
      docker push $DOCKER_REPO/zeppelin:$ZEPPELIN_VERSION-$version-$package-$MINOR_VERSION
    fi
  done
done
