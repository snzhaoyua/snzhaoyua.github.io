#!/usr/bin/env bash
USER_NAME=
PASSWORD=
WORKDIR="/home/mysql/temp/"
mysqldump_command="/data01/chroot/usr/local/mysql5.7.23/bin/mysqldump"


function usage {
  echo "Usage: open multidump.sh and fill in user_name and password manually.i'm too tired."
  echo "Do not support -uroot, using -u root please."
  # too 2
  exit 2
}

[[ -z "${USER_NAME}" ]] && usage
[[ -z "${PASSWORD}" ]] && usage

mysql -u${USER_NAME} -p${PASSWORD} -A --skip-column-names -e"SELECT CONCAT(table_schema,'.',table_name) FROM information_schema.tables WHERE table_schema NOT IN ('information_schema','mysql','performance_schema','sys')" > ${WORKDIR}/listOfTables

function dumpIt {
    dumpCommand="${mysqldump_command} -u${USER_NAME} -p${PASSWORD} --single-transaction --quick --routines --triggers --hex-blob "
    ${dumpCommand} $@ |gzip > ${WORKDIR}/backup/${1}_${2}.sql.gz &
}

multidump() {
    rm -rf ${WORKDIR}/backup
    mkdir -p ${WORKDIR}/backup

    COMMIT_COUNT=0
    COMMIT_LIMIT=10
    error_views_file="${WORKDIR}/error_list"
    DBTBS=(`cat ${WORKDIR}/listOfTables`)
    i=1
    for DBTB in ${DBTBS[@]};do
        echo "processing $i/${#DBTBS[@]}"
        ((i++))
        DB=`echo ${DBTB} | sed 's/\./ /g' | awk '{print $1}'`
        TB=`echo ${DBTB} | sed 's/\./ /g' | awk '{print $2}'`
        if [[ "X"`grep -w ${DBTB} ${error_views_file}` != X"" ]];then
            echo skip "${DBTB}"
            continue
        fi
        dumpIt ${DB} ${TB}
        (( COMMIT_COUNT++ ))
        if [[ ${COMMIT_COUNT} -eq ${COMMIT_LIMIT} ]]
        then
            COMMIT_COUNT=0
            wait
        fi
    done
    if [[ ${COMMIT_COUNT} -gt 0 ]]
    then
        wait
    fi
}

multidump

