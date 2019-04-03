#!/bin/bash


## TODO 后期OC场景注意检查jar包调用此处的时候会不会有影响


# 此脚本需要轻量，因此日志等框架不太适合引入

function log_info {
    echo `date '+%y-%m-%d %H:%M:%S'`" " $@
}
function log_error {
    echo `date '+%y-%m-%d %H:%M:%S'`" " $@ >&2
}
function log_info_green()
{
    echo -e `date '+%y-%m-%d %H:%M:%S'`" " "\e[32m$@\e[0m"
}
function log_error_red()
{
    echo  -e `date '+%y-%m-%d %H:%M:%S'`" " "\e[31m$@\e[0m" >&2
}

user="`whoami`"
if [[ "Xmysql" != "X${user}" ]];then
    # tee not exist
    log_error_red "Please execute this script using mysql user."
    exit 1
fi

function mysql_command()
{

	local command=$1
    mysql --login-path=local --skip-column-names -e "$command"
    return $?
}

function mysql_command_with_dollar()
{
    local command=$1
    temp_sql_file=/opt/mysql/$$.sql
    echo "${command}" > ${temp_sql_file}
    chown mysql: ${temp_sql_file}
    mysql --login-path=local < ${temp_sql_file}
    result=$?
    rm -rf ${temp_sql_file}
    return ${result}
}

######################################################################
#   FUNCTION   : getFileType
#   DESCRIPTION: 获取文件类型
#   USAGE: type=`getFileType "${fileName}"`
######################################################################
function getFileType()
{
    function stringContain()
    {
       [[ -z "${1##*$2*}" ]] && {
           [[ -z "$2" ]] || [[ -n "$1" ]] ;
       } ;
    }

    fileName=$1
    local result="";
    if stringContain "${fileName}" '.' ;then
        result="${fileName##*.}"
    else
        result="NOTYPE"
    fi
    echo "${result}" ## do not replace with log
}


backup_file_path=$1

if [[ ! -f "${backup_file_path}" ]];then
     log_error_red "[check] backup file not found, exit".
     echo "1"  ## 这是java程序调用使用的？？
     exit 1
fi

# TODO 备份恢复jar使用到了这里，但是没有实际用处，后面OC版本再整改
## 为了防止有些用户磁盘不够仍然强行备份，此处可以控制恢复过程中是否还备份旧的 /opt/mysql/data
backup_old_data="$2"

if [[ -z "${backup_old_data}" ]];then
    backup_old_data="true"
fi
backup_old_data=`echo "${backup_old_data}"|tr A-Z a-z`
if [[ "X${backup_old_data}" != "Xtrue" ]];then
    backup_old_data="false"
fi

RESTORE_DESTINATION="/opt/mysql/data"

recover_log="`dirname ${backup_file_path}`"/recover.log
touch ${recover_log}

log_info_green "backup_file_path is ${backup_file_path}"
log_info_green "backup_old_data is ${backup_old_data}."
log_info_green "restore_data_dir_destination is ${RESTORE_DESTINATION}."


function mysqlbackup_restore()
{
    log_info_green "[1/8]do some checking..."
    checkBeforeRestore

    log_info_green "[2/8]freezing mysql.(touching /opt/mysql/backup_flag)"
    preventMysqlAutoStart

    log_info_green "[3/8]stopping mysql."
    stopMysql

    log_info_green "[4/8]restoring data to /opt/mysql/data."
    _restore "$1"

    log_info_green "[5/8]start mysql..."
    startMysql

    ## reset slave, otherwise slave thread will not start
    log_info_green "[6/8]clear binlog and relay log."
    mysql_command "stop slave; reset slave; reset master;" || log_error_red "reset slave failed."

    log_info_green "[7/8]trying to restore replication..."
    replication

    log_info_green "[8/8]stop freezing mysql.(deleting /opt/mysql/backup_flag)"
    releaseMysqlAutoStart

    log_info_green "Restore completed successfully."

}

function replication()
{

    source /opt/mysql/.bashrc
    if [[ -z "${ip_cluster_a}" ||  -z "${ip_cluster_b}" ]];then
        log_error_red "cannot get master or slave ip, you have to restore replication manually."
        return
    fi
    log_info "got two ip: [${ip_cluster_a},${ip_cluster_b}], testing..."
    ips=`ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
    # 测试两个ip是不是都不是本机的ip
    if ! echo "${ips}"|grep -w "${ip_cluster_a}" && ! echo "${ips}"|grep -w "${ip_cluster_b}";then
        log_error_red "/opt/mysql/.bashrc ips invalid."
        return
    fi

    # 获取另一台机器的ip
    another_ip=""
    if echo "${ips}"|grep -w "${ip_cluster_a}";then
        another_ip=${ip_cluster_b}
    fi
    if echo "${ips}"|grep -w "${ip_cluster_b}";then
        another_ip=${ip_cluster_a}
    fi
    log_info "another_ip is ${another_ip}"
    # 从恢复完成的数据库查询出的replicator ip（理应是非本机ip）
    replicator_ip=`mysql_command "select host from mysql.user where user='replicator';"`
    [[ -z "${replicator_ip}" ]] && { log_error_red "can not find replicator ip, did you drop replicator user? \
    can't set up replication, you have to do it manually.";return 1; }

    if echo "${ips}"|grep -w "${replicator_ip}";then
        ##
        master_ip="";
        log_info_green "restore using file backed up from the other node. "
        log_info_green "fixing up replication. "
        command="SET sql_log_bin=0;
        update mysql.user set host='${another_ip}' where user='replicator';
        flush privileges;
        SET sql_log_bin=1;"
        mysql_command "${command}"
        mysql_command "STOP SLAVE;CHANGE MASTER TO MASTER_HOST='${another_ip}', MASTER_AUTO_POSITION=1 FOR CHANNEL 'rpl1';START SLAVE;"
        [[ $? -eq 0 ]] && { log_error_red "success. you may need to execute [STOP SLAVE;START SLAVE;] on another node."; }
    else
        log_info_green "restore using file backed up from this very node."
        log_info_green "please restore this file on another node also."
        log_error_red "after that, you may need to execute [STOP SLAVE;START SLAVE;] on this node."
    fi

}

function releaseMysqlAutoStart()
{
    RESTORE_FLAG="/opt/mysql/backup_flag"
    [[ -f "${RESTORE_FLAG}" ]] && rm "${RESTORE_FLAG}" -rf
    [[ ! -f "${RESTORE_FLAG}" ]] && log_info_green "restore lock ${RESTORE_FLAG} released."
}

function _restore()
{
    binFile="$1"
    binFile_dir="`dirname ${binFile}`"


    ## 1 backup or delete data dir
    if [[ "X${backup_old_data}" == "Xtrue" ]];then
        ## move dataDir to anywhere else
        log_info_green "[4.1/8]backing up mysql data dir."
        backedup_data=/opt/backup/mysql/data_dirs/data_`date '+%Y-%m-%d-%H-%M-%S'`
        mkdir -p "${backedup_data}" 2>/dev/null
        log_info "moving files under ${RESTORE_DESTINATION} to ${backedup_data}. It might cost plenty of time according to data and disk."
        mv "${RESTORE_DESTINATION}"/* "${backedup_data}"
        [[ $? -ne 0 ]] && { log_error_red "failed to backup data dir."; exit 1; }
        log_info "moved ${RESTORE_DESTINATION}/* to ${backedup_data}."
    else
        log_info_green "[4.1/8]backup_old_data is ${backup_old_data}, deleting ${RESTORE_DESTINATION}."
        rm "${RESTORE_DESTINATION}"/* -rf
    fi

    ## 2 executing mysqlbackup
    echo "`date '+%y-%m-%d %H:%M:%S'`" > "${recover_log}"
    log_info_green "[4.2/8]restoring data."
    log_info "restoring data, you can check log by tailf ${recover_log}"
    mysqlbackup --defaults-file=/opt/mysql/.my.cnf  --login-path=local \
    --backup-image="${binFile}" --backup-dir="${binFile_dir}" \
    --datadir=/opt/mysql/data/workdbs --uncompress copy-back-and-apply-log 2>>"${recover_log}" &

    while ! grep "^mysqlbackup completed OK!" "${recover_log}";do
        echo -e ".\c"
        sleep 1
    done

    [[ $? -ne 0 ]] && { log_error_red "failed to restore, please check ${recover_log}"; exit 1; }

    ## 3 mkdir
    log_info_green "[4.3/8]making necessary directories."
    mkdir -p /opt/mysql/log/error
    mkdir -p /opt/mysql/log/audit
    touch /opt/mysql/log/audit/audit.log
    touch /opt/mysql/log/error/mysqld.log
    mkdir -p /opt/mysql/data/binlog/binlog
    mkdir -p /opt/mysql/data/binlog/relay
    mkdir -p /opt/mysql/data/tmp

}

function preventMysqlAutoStart()
{
## 0. stop mysql forever
    RESTORE_FLAG="/opt/mysql/backup_flag"
    [[ -f "${RESTORE_FLAG}" ]] && rm "${RESTORE_FLAG}" -rf
    log_info "touching restore flag /opt/mysql/backup_flag, mysql won't start automatically."
    touch "${RESTORE_FLAG}" ## mysql user

}

function startMysql()
{
    log_info "starting mysql."

    mysql.server start

    mysql.server status|grep "running"|grep "done"

    [[ $? -ne 0 ]] && { log_error_red "failed to start mysql, please check /opt/mysql/log/error/mysqld.log, exit."; exit 1; }

    log_info "done starting mysql."
}


function stopMysql()
{
    log_info "stopping mysql."

    mysql.server stop

    mysql.server status|grep "not running"|grep "failed"

    sleep 2

    [[ $? -ne 0 ]] && { log_error_red "failed to stop mysql, won't restore mysql, exit."; exit 1; }

}

function checkBeforeRestore()
{

    ## 此值未放开配置，所以暂时写死 20190321
    
    [[ ! -d "${RESTORE_DESTINATION}/workdbs" ]] && { log_error_red "can't find /opt/mysql/data/workdbs, is it a broken mysql? we'll try to restore but making no assurance."; sleep 3; }

    ## lsof -L /opt/mysql/data
    ## 为了防止僵尸线程占用磁盘资源
     killall mysqld 2>/dev/null

    datadir_size=`du "${RESTORE_DESTINATION}" --max-depth=0|awk '{print $1}'`
    datadir_size_human=`du -h "${RESTORE_DESTINATION}" --max-depth=0|awk '{print $1}'`
    disk_free_size=`df /opt/mysql|awk 'NR>1{print $4}'`
    if [[ "X${backup_old_data}" == "Xtrue" && "${disk_free_size}" -lt "${datadir_size}" ]];then
        log_info "checking disk space..."
        log_error_red "old data_dir has a size of ${disk_free_size}K, larger than free disk space which is ${disk_free_size}."
        log_error_red "if we restore data, mysqlbackup will encounter 'NO SPACE LEFT ON DISK ERROR'."
        log_error_red "please make sure free space larger than ${datadir_size_human} at least."
        log_error_red "backup won't continue. exit."
        exit 1
    fi
}


function databasesRestore()
{

        log_info "[check]found backup file ${backup_file_path}, begin to recover..."
        log_info "[check]checking file type ${backup_file_path}"

        type=`getFileType "${backup_file_path}"`
        log_info ${backup_file_path} is ${type}
        [[ "X${type}" == "NOTYPE" ]] && { log_error_red "invalid type"; exit 1; }
        [[ "X${type}" != "Xgz" && "X${type}" != "Xbin" ]] &&  { log_error_red "invalid type"; exit 1; }


        ## if gz ， 是mysqldump，如果是 bin，是mysqlbackup
        if [[ "X${type}" == "Xgz" ]];then
            log_info "found mysqldump file, please make sure mysql has been started and in normal status."
            gunzip < ${backup_file_path} | mysql --login-path=local
        else
            log_info "found mysqlbackup file, you should stop mysql first but in case you didn't , we will stop it again."
            mysqlbackup_restore ${backup_file_path}
        fi

        if [[ $? -ne 0 ]];then
            log_info "[restore] failed to restore ! ! !" >&2
            log_info "1"
            return 1
        fi
	    return 0

}



#执行数据恢复
databasesRestore
exit 0
