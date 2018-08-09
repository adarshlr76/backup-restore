### Set server settings
HOST="localhost"
PORT="27017" # default mongoDb port is 27017

#set the path where the collections are backedup
#BACKUP_PATH="/tmp/backup3" # do not include trailing slash

MONGO_RESTORE_BIN_PATH="$(which mongorestore)"

usage() { echo "Usage: $0 [-p <backup_path>] " 1>&2; exit 1; }

while getopts ":p:" o; do
    case $o in
        p)
            BACKUP_PATH=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

if [ -z "$BACKUP_PATH" ]; then
   usage
fi




echo; echo "=> Restoring Vision database : $HOST:$PORT";

$MONGO_RESTORE_BIN_PATH --drop --host $HOST:$PORT --db vision $BACKUP_PATH/vision --gzip >> /dev/null
