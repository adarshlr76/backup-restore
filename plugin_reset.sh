usage() { echo "Usage: $0 [-b <build_path>] [-p <backup_path>]" 1>&2; exit 1; }

while getopts ":b:" o; do
    
    case $o in
        p)
            BACKUP_PATH=${OPTARG}
            ;;
        b)
            BUILD_PATH=${OPTARG}
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


sudo rm -rf $BUILD_PATH/es6-unbundled/plugins/*.*
sudo rm -rf $BUILD_PATH/es5-bundled/plugins/*.*

#mongo vision --eval "printjson(db.plugin.drop())"
$MONGO_RESTORE_BIN_PATH --drop --host $HOST:$PORT --db vision --collection plugin $BACKUP_PATH >> /dev/null