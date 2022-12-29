#!/bin/bash

set -euxo pipefail

output_dir=$1

git_commit_hash=${2:-$(git rev-parse HEAD)}

git_version_string=${3:-$(git log --date=format:%Y%m%d --pretty=~git%cd.%h -n 1)}

build_number=${GITHUB_RUN_NUMBER:=0}

ros_distro=${ROS_DISTRO:=galactic}

iname=${PACKAGE_NAME:=fognav-msgs}

iversion=${PACKAGE_VERSION:=latest}

docker build \
  --build-arg UID=$(id -u) \
  --build-arg GID=$(id -g) \
  --build-arg ROS_DISTRO=${ros_distro} \
  --build-arg PACKAGE_NAME=${iname} \
  --build-arg GIT_RUN_NUMBER=${build_number} \
  --build-arg GIT_COMMIT_HASH=${git_commit_hash} \
  --build-arg GIT_VERSION_STRING=${git_version_string} \
  --pull \
  -f Dockerfile.build_deb -t "${iname}-build:${iversion}" .

mkdir -p ${output_dir}

docker create -ti --name ${iname}-build-temp ${iname}-build:latest bash
docker cp ${iname}-build-temp:/main_ws/build_output ${output_dir}
docker rm -f ${iname}-build-temp

exit 0
