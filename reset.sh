
usage() { echo "Usage: $0 [-i <specific_collections_filename>] " 1>&2; exit 1; }

while getopts ":i:" o; do
    case $o in
        i)
            COLLECTIONS_CONFIG=${OPTARG}
            flag='1'
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "$COLLECTIONS_CONFIG" ]; then
   usage
fi

#delete the collections specified in filename
if [[ -v COLLECTIONS_CONFIG ]] && [ -e $COLLECTIONS_CONFIG ]; then
    while IFS= read -r col_name
    do
    [[ $col_name = \#* ]] && continue
    mongo vision --eval "printjson(db.$col_name.drop())"
    done < $COLLECTIONS_CONFIG
fi
