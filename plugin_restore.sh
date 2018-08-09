#!/bin/bash

### Set server settings
HOST="localhost"
PORT="27017" # default mongoDb port is 27017

#BACKUP_PATH="/tmp/backup3" # do not include trailing slash

usage() { echo "Usage: $0 [-p <backup_path>] [-b <build_path>]" 1>&2; exit 1; }

while getopts ":b:p:" o; do
    
    case $o in
        b)
            BUILD_PATH=${OPTARG}
            flag='1'
            ;;

        p)
            BACKUP_PATH=${OPTARG}
            flag='1'
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))


if [ -z "${BUILD_PATH}" ] || [ -z "${BACKUP_PATH}" ]; then
    usage
fi

#[ ! -d $BUILD_PATH/es6-unbundled/plugins ] && mkdir -p $BUILD_PATH/es6-unbundled/plugins || :

tar -xvzf $BACKUP_PATH/plugins.tar.gz -C /

MONGO_RESTORE_BIN_PATH="$(which mongorestore)"

echo; echo "=> Restoring Vision database : $HOST:$PORT";

$MONGO_RESTORE_BIN_PATH --drop --host $HOST:$PORT --db vision $BACKUP_PATH/vision --gzip >> /dev/null
