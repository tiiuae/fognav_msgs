#!/bin/bash

set -eo pipefail

usage() {
	echo "
Usage: $(basename "$0") [-h] [-b nbr] [-d dist]
 -- Generate debian package from fog_sw module.
Params:
    -h  Show help text.
    -b  Build number. This will be tha last digit of version string (x.x.N).
    -d  Distribution string in debian changelog.
    -g  Git commit hash.
    -v  Git version string
    -o  Output dir
"
	exit 0
}

check_arg() {
	if [ "$(echo $1 | cut -c1)" = "-" ]; then
		return 1
	else
		return 0
	fi
}

error_arg() {
	echo "$0: option requires an argument -- $1"
	usage
}

# this should refer to the repo's root dir.
# this used some clever tricks before, but now using just assumption that this is invoked from repo root.
mod_dir="$(pwd)"
build_nbr=0
distr=""
version=""
git_commit_hash=""
git_version_string=""
output_dir="build_output/"

while getopts "hb:d:g:v:o:" opt
do
	case $opt in
		h)
			usage
			;;
		b)
			check_arg $OPTARG && build_nbr=$OPTARG || error_arg $opt
			;;
		d)
			check_arg $OPTARG && distr=$OPTARG || error_arg $opt
			;;
		g)
			check_arg $OPTARG && git_commit_hash=$OPTARG || error_arg $opt
			;;
		v)
			check_arg $OPTARG && git_version_string=$OPTARG || error_arg $opt
			;;
		o)
			check_arg $OPTARG && output_dir=$OPTARG || error_arg $opt
			;;
		\?)
			usage
			;;
	esac
done

if [[ "$git_commit_hash" == "0" || -z "$git_commit_hash" ]]; then
	git_commit_hash="$(git rev-parse HEAD)"
fi
if [[ "$git_version_string" == "0" || -z "$git_version_string" ]]; then
	git_version_string="$(git log --date=format:%Y%m%d --pretty=~git%cd.%h -n 1)"
fi

## Remove trailing '/' mark in module dir, if exists
mod_dir=$(echo $mod_dir | sed 's/\/$//')

## Debug prints
echo 
echo "[INFO] mod_dir: ${mod_dir}."
echo "[INFO] build_nbr: ${build_nbr}."
echo "[INFO] distr: ${distr}."
echo "[INFO] git_commit_hash: ${git_commit_hash}."
echo "[INFO] git_version_string: ${git_version_string}."

cd $mod_dir

## Generate package
echo "[INFO] Creating deb package..."
### ROS2 Packaging

### Create version string
version=$(grep "<version>" package.xml | sed 's/[^>]*>\([^<"]*\).*/\1/')

echo "[INFO] Version: ${version}."

if [ -e ${mod_dir}/ros2_ws ]; then
	# From fog-sw repo.
	source ${mod_dir}/ros2_ws/install/setup.bash
fi
if [ -e ${mod_dir}/deps_ws ]; then
	source ${mod_dir}/deps_ws/install/setup.bash
fi

# Speed up builds.
# In addition to the following environmental variable,
# --parallel flag is needed in "fakeroot debian/rules binary" call.
export DEB_BUILD_OPTIONS="parallel=`nproc`"

# generates makefile at debian/rules, which is used to invoke the actual build.
bloom-generate rosdebian --os-name ubuntu --os-version jammy --ros-distro ${ROS_DISTRO} --place-template-files

sed -i "s/@(DebianInc)@(Distribution)/@(DebianInc)/" debian/changelog.em

# modify the distribution in the template and ignore warnings from sed and not stop the script.
[ ! "$distr" = "" ] && sed -i "s/@(Distribution)/${distr}/" debian/changelog.em || :

bloom-generate rosdebian --os-name ubuntu --os-version jammy --ros-distro ${ROS_DISTRO} --process-template-files -i ${build_nbr}${git_version_string}

sed -i 's/^\tdh_shlibdeps.*/& --dpkg-shlibdeps-params=--ignore-missing-info/g' debian/rules

sed -i "s/\=\([0-9]*\.[0-9]*\.[0-9]*\*\)//g" debian/control

debian/rules clean

# the actual build process magic.
# internally it calls debhelper with something like "$ dh binary --parallel -v --buildsystem=cmake --builddirectory=.obj-x86_64-linux-gnu"
# debhelper uses cmake to run the build, and after it wrap it in a .deb package.
debian/rules "binary --parallel"

mkdir -p "$output_dir"

echo "[INFO] Move debian packages."
cp ${mod_dir}/../*.deb "$output_dir"
# Some components do not produce ddeb packages.
if ls ${mod_dir}/../*.ddeb 1> /dev/null 2>&1; then
	cp ${mod_dir}/../*.ddeb "$output_dir"
fi

echo "[INFO] Done."
exit 0