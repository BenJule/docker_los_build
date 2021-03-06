#!/bin/bash
#
# Test script file that maps itself into a docker container and runs
#
# Example invocation:
#
# $ LOS_VOL=$PWD/build ./build-nougat.sh
#
set -ex

if [ "$1" = "docker" ]; then
    TEST_BRANCH=${TEST_BRANCH:-lineage-17.1}
    TEST_URL=${TEST_URL:-https://github.com/LineageOS/android}

    cpus=$(grep ^processor /proc/cpuinfo | wc -l)

    repo init --depth 1 -u "$TEST_URL" -b "$TEST_BRANCH"

    # Use default sync '-j' value embedded in manifest file to be polite
    repo sync

    prebuilts/misc/linux-x86/ccache/ccache -M 4G

    source build/envsetup.sh
    lunch jfltexx_arm-eng
    make -j $cpus
else
    los_url="https://raw.githubusercontent.com/BenJule/docker_los_build/master/utils/los"
    args="bash run.sh docker"
    export LOS_EXTRA_ARGS="-v $(cd $(dirname $0) && pwd -P)/$(basename $0):/usr/local/bin/run.sh:ro"
    export LOS_IMAGE="benlue/los-build:latest"

    #
    # Try to invoke the los wrapper with the following priority:
    #
    # 1. If LOS_BIN is set, use that
    # 2. If los is found in the shell $PATH
    # 3. Grab it from the web
    #
    if [ -n "$LOS_BIN" ]; then
        $LOS_BIN $args
    elif [ -x "../utils/los" ]; then
        ../utils/los $args
    elif [ -n "$(type -P los)" ]; then
        los $args
    else
        if [ -n "$(type -P curl)" ]; then
            bash <(curl -s $los_url) $args
        elif [ -n "$(type -P wget)" ]; then
            bash <(wget -q $los_url -O -) $args
        else
            echo "Unable to run the los binary"
        fi
    fi
fi
