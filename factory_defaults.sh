## Set server settings
HOST="localhost"
PORT="27017" # default mongoDb port is 27017


# sudo rabbitmqctl add_user vision vision
# sudo rabbitmqctl set_permissions -p / vision ".*" ".*" ".*"
# sudo rabbitmqctl set_user_tags vision management

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

echo; echo "=> Restoring Vision factory defaults : $HOST:$PORT";

mongo vision --eval "printjson(db.dropDatabase())"

$MONGO_RESTORE_BIN_PATH --drop --host $HOST:$PORT --db vision $BACKUP_PATH >> /dev/null




