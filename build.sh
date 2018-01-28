#!/usr/bin/env bash

declare -A spark_versions=( ["2.2.1-1-hadoop-2.6"]="2.1.0-2.2.1-1-hadoop-2.6" ["2.2.1-1-hadoop-2.7"]="2.1.0-2.2.1-1-hadoop-2.7" )
ZEPPELIN_VERSION=0.7.3
RELEASE=${RELEASE:-2}
DOCKER_REPO=${DOCKER_REPO:-maibornwolff}

cd docker
for version in "${!spark_versions[@]}"; do
  for package in all netinst; do
    echo "Building zeppelin:$ZEPPELIN_VERSION-$RELEASE-$package-$version"
    docker build -t zeppelin:$ZEPPELIN_VERSION-$RELEASE-$package-$version --build-arg SPARK_VERSION=${spark_versions[$version]} --build-arg ZEPPELIN_VERSION=$ZEPPELIN_VERSION --build-arg PACKAGE_TYPE=$package .
    if [ ${PUSH:-"0"} == "1" ]; then
      docker tag zeppelin:$ZEPPELIN_VERSION-$RELEASE-$package-$version $DOCKER_REPO/zeppelin:$ZEPPELIN_VERSION-$RELEASE-$package-$version
      docker push $DOCKER_REPO/zeppelin:$ZEPPELIN_VERSION-$RELEASE-$package-$version
    fi
  done
done
