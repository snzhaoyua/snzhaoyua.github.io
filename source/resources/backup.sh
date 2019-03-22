#!/bin/bash

#backup
function backup_data()
{

    backupTool="mysqlbackup"
    if [[ "X$1" == "Xmysqldump" ]];then
        backupTool="mysqldump"
    fi

	echo "`date '+%Y-%m-%d %H %M %S'`:begin execute backup_data" >> /opt/backup/mysql/backup_data/backupanddelete.log

	if [ ! -d /opt/backup/mysql/backup_data ];then
		echo "`date '+%Y-%m-%d %H %M %S'`:the dir:/backup/backup_data is not exist" >> /opt/backup/mysql/backup_data/backupanddelete.log
		return 1
	fi

	if [ ! -d /opt/backup/mysql/backup_data ];then
	 echo "the dir:/backup/backup_data is not exist!" >> /opt/backup/mysql/backup_data/backupanddelete.log
	 return 1
	fi
	cd /opt/backup/mysql/backup_data
	local dirNum=$(ls -l |grep "^d"|wc -l)
	if [ ${dirNum} -ge 2 ];then
	  local deleteDir=$(ls -l |grep "^d" | awk -F ' ' '{print $9}'|awk 'NR==1{print}')
	  local time=$(stat -c %Y ${deleteDir})
	  for dir in $(ls -l |grep "^d" | awk -F ' ' '{print $9}')
	  do
		local fileCreatDate=$(stat -c %Y ${dir})
		if [[ ${fileCreatDate} < ${time} ]];then
		  deleteDir=${dir}
		fi
	  done

	  if [ -n "${deleteDir}" ];then
		#clear old data
		rm -rf ${deleteDir}
	  fi
	fi

	#create backup dir
	local backupDir="${backupTool}_`date '+%Y-%m-%d-%H-%M-%S'`"
	mkdir /opt/backup/mysql/backup_data/${backupDir}
	chmod 750 -R /opt/backup/mysql/backup_data/${backupDir}
	#refresh binlog
	mysql --login-path=local<<EOF
		flush logs;
EOF

	#backup mysql，gzip
	backupDir=/opt/backup/mysql/backup_data/${backupDir}
    echo "start to backup mysql to ${backupDir}"
    backupFile=""
	if [[ "X${backupTool}" == "Xmysqlbackup" ]];then
	    tempdir=${backupDir}/temp
	    mkdir ${backupDir}/temp
	    backupFile="${backupDir}/mysqlbackup_data_`date '+%Y-%m-%d'`.sql.bin"
	    mysqlbackup --login-path=local --compress --compress-level=5 --limit-memory=1024 --read-threads=10 --process-threads=15 \
	    --write-threads=10 --backup-dir=${tempdir} --backup-image="${backupFile}" backup-to-image >> ${backupDir}/mysqlbackup.log 2>&1 &

	    while ! grep "^mysqlbackup completed OK!" "${backupDir}/mysqlbackup.log";do
            echo -e ".\c"
            sleep 1
        done

	else
	    backupFile="${backupDir}/mysqldump_data_`date '+%Y-%m-%d'`.sql.gz"
	    mysqldump --login-path=local --all-databases 2>${backupDir}/mysqldump.log | gzip > "${backupFile}"
	fi

	if [ $? -ne 0 ];then
		echo "`date '+%Y-%m-%d %H %M %S'`:backup_data is failed" >> /opt/backup/mysql/backup_data/backupanddelete.log
		return 1
	fi

	echo "`date '+%Y-%m-%d %H %M %S'`:end execute backup_data" >> /opt/backup/mysql/backup_data/backupanddelete.log
	echo "done. backup file generated at ${backupFile}"
	chown mysql:oinstall /opt/backup/mysql/backup_data/ -R
	return 0
}

## TODO 后期OC场景注意检查jar包调用此处的时候会不会有影响
user=`whoami`
if [[ "Xmysql" != "X${user}" ]];then
    # tee not exist
    echo "Please execute this script using mysql user."
    echo "Please execute this script using mysql user." >> /opt/backup/mysql/backup_data/backupanddelete.log
    chown mysql: /opt/backup/mysql/backup_data/backupanddelete.log
    exit 1;
fi

backup_data $@
