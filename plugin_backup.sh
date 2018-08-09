#!/bin/bash

### Set server settings
HOST="localhost"
PORT="27017" # default mongoDb port is 27017

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

# Create BACKUP_PATH directory if it does not exist
[ ! -d $BACKUP_PATH ] && mkdir -p $BACKUP_PATH || :

tar -cvzf $BACKUP_PATH/plugins.tar.gz $BUILD_PATH/es6-unbundled/plugins


# Auto detect unix bin paths, enter these manually if script fails to auto detect
MONGO_DUMP_BIN_PATH="$(which mongodump)"

echo; echo "=> Backing up Vision database : $HOST:$PORT";

$MONGO_DUMP_BIN_PATH --host $HOST:$PORT --db vision --collection plugin --gzip --out $BACKUP_PATH >> /dev/null
if [ $? -eq 0 ]; then
    echo "=> Success: `du -sh $BACKUP_PATH`"; echo;
else
    echo "!!!=> Failed to create backup file"; echo;
fi

$MONGO_DUMP_BIN_PATH --host $HOST:$PORT --db vision --collection setting --gzip --out $BACKUP_PATH >> /dev/null
if [ $? -eq 0 ]; then
    echo "=> Success: `du -sh $BACKUP_PATH`"; echo;
else
    echo "!!!=> Failed to create backup file"; echo;
fi
