#!/bin/bash

### Set server settings
HOST="localhost"
PORT="27017" # default mongoDb port is 27017
BACKUP_PATH="/tmp/backup3" # do not include trailing slash
#FILE_NAME="visiondb" #Creates a file visiondb.archive



usage() { echo "Usage: $0 [-e <exclude_collections_file_name>] [-i <specific_collections_filename>] [-p <backup_path>] -c" 1>&2; exit 1; }

while getopts ":e:i:p:c" o; do
    case $o in
        e)
            EXCLUDE_COLLECTIONS_CONFIG=${OPTARG}
            flag='1'
            ;;
        i)
            COLLECTIONS_CONFIG=${OPTARG}
            flag='1'
            ;;
        c)
            ENTIREDB="YES"
            #OPTIND=$OPTIND-1
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

if [ -z "$flag" ]; then
   usage
fi


# Set where database backups will be stored and the config file names

# if specific $collection included in COLLECTIONS_CONFIG $collection.visiondb.archive will be created
# EXCLUDE_COLLECTIONS_CONFIG="collections567" #collections to be excluded
# COLLECTIONS_CONFIG="models" #specific collections to take backup
# #ENTIREDB="entire_visiondb" #if set entire db will be backed up


# Auto detect unix bin paths, enter these manually if script fails to auto detect
MONGO_DUMP_BIN_PATH="$(which mongodump)"



#get the collections to be excluded if exclude collections config file present
if [[ -v EXCLUDE_COLLECTIONS_CONFIG ]] && [ -e $EXCLUDE_COLLECTIONS_CONFIG ]; then
    while IFS= read -r col_name
    do
    [[ $col_name = \#* ]] && continue
    exclude="$exclude --excludeCollection $col_name"
    done < $EXCLUDE_COLLECTIONS_CONFIG
fi



# Create BACKUP_PATH directory if it does not exist
[ ! -d $BACKUP_PATH ] && mkdir -p $BACKUP_PATH

cwd=`pwd`
if [[ -v COLLECTIONS_CONFIG ]]; then
    COLLECTIONS_CONFIG="$cwd/$COLLECTIONS_CONFIG"
fi

if [[ -v EXCLUDE_COLLECTIONS_CONFIG ]]; then
    EXCLUDE_COLLECTIONS_CONFIG="$cwd/$EXCLUDE_COLLECTIONS_CONFIG"
fi


# Ensure directory exists before dumping to it

if [ -d "$BACKUP_PATH" ]; then
    
    cd $BACKUP_PATH
    echo; echo "=> Backing up Vision database : $HOST:$PORT";
    
    #get the collections to be included in the backuup if collections config file present
    if [[ -v COLLECTIONS_CONFIG ]] && [ -e $COLLECTIONS_CONFIG ]; then
        
        echo; echo "=> Backing up selected collections : $HOST:$PORT";

        while IFS= read -r incl_col_name
        do
            [[ $incl_col_name = \#* ]] && continue
            $MONGO_DUMP_BIN_PATH --host $HOST:$PORT --db vision --collection $incl_col_name --gzip --out $BACKUP_PATH >> /dev/null
            if [ $? -eq 0 ]; then
                echo "=> Success: `du -sh $BACKUP_PATH`"; echo;
            else
			    echo "!!!=> Failed to create backup file"; echo;
            fi

        done < $COLLECTIONS_CONFIG
        
    fi
    
    if [[ -v EXCLUDE_COLLECTIONS_CONFIG ]] && [ -e $EXCLUDE_COLLECTIONS_CONFIG ]; then

        echo; echo "=> Backing up Vision database with exclusions: $HOST:$PORT";

        $MONGO_DUMP_BIN_PATH --host $HOST:$PORT --db vision $exclude --out $BACKUP_PATH --gzip >> /dev/null
        if [ $? -eq 0 ]; then
            echo "=> Success: `du -sh $BACKUP_PATH`"; echo;
        else
    	    echo "!!!=> Failed to create backup file"; echo;
        fi

    fi
    if [[ -v ENTIREDB ]]; then
        echo; echo "=> Backing up entire Vision database : $HOST:$PORT";

        echo "$MONGO_DUMP_BIN_PATH --host $HOST:$PORT --db vision --out $BACKUP_PATH --gzip >> /dev/null"
         $MONGO_DUMP_BIN_PATH --host $HOST:$PORT --db vision --out $BACKUP_PATH --gzip >> /dev/null
        if [ $? -eq 0 ]; then
            echo "=> Success: `du -sh $BACKUP_PATH`"; echo;
        else
    	    echo "!!!=> Failed to create backup file"; echo;
        fi

    fi
else
    echo "!!!=> Failed to create backup path: $BACKUP_PATH"    
fi

echo $cmd
