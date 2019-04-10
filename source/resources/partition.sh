#!/bin/bash

CURRENT_PATH=""
LOG_HOME="/var/log"

######################################################################
#   FUNCTION    : mkLogDir
#   DESCRIPTION : 创建日志文件
#   CALLS       : 无
#   CALLED BY   : 任何需要此功能的函数
#   INPUT       : 无
#   READ GLOBVAR: 无
#   WRITE GLOBVAR: 无
#   RETURN       : 0
######################################################################
mkLogDir()
{
	
	#判断目录是否存在
    if [ -e "${LOG_HOME}/partition.log" ];then
        chmod 750 ${LOG_HOME}/partition.log
    else
        mkdir -p ${LOG_HOME}
		touch ${LOG_HOME}/partition.log
        chmod 750 ${LOG_HOME}/partition.log
    fi

}

######################################################################
#   FUNCTION    : log
#   DESCRIPTION : 日志函数
#   CALLS       : 无
#   CALLED BY   : 本脚本文件中打印日志使用
#   INPUT       : 无
#   READ GLOBVAR: 无
#   WRITE GLOBVAR: 无
#   RETURN       : 0
######################################################################
log()
{
    echo -e "[ `date +%Y-%m-%d_%r` ] $@" >&2
    echo -e "[ `date +%Y-%m-%d_%r` ] $@" >> ${LOG_HOME}/partition.log
    
    return 0
}

######################################################################
#   FUNCTION    : partion
#   DESCRIPTION : 磁盘分区
#   CALLS       : 无
#   CALLED BY   : 本脚本中磁盘分区的总入口
#   INPUT       : 无
#   READ GLOBVAR: 无
#   WRITE GLOBVAR: 无
#   RETURN       : 0
######################################################################
partion()
{
    # 对其余硬盘进行分区，根据服务器类型处理方式不一样
    
    format_volume $2 $1 || { log "format_volume $1 failed."; return 1; }
    
    log "partion success"

    return 0
}

######################################################################
#   FUNCTION    : format_volume
#   DESCRIPTION : 对挂载卷进行分区、格式化、挂载处理。本函数将输入盘符
#                 整体划成一个分区，并进行处理
#   CALLS       : 无
#   CALLED BY   : partion
#   INPUT       : 参数1：盘符编号；参数2：挂载点
#   READ GLOBVAR: 无
#   WRITE GLOBVAR: 无
#   RETURN       : 0
######################################################################
format_volume()
{
    DISK_NUM=$1
    PATHS=$2
    
    # 获取磁盘个数
    disk_count=`cat /proc/partitions | sort | grep -v "name" |grep -v "loop" |awk '{print $4}'| sed /^[[:space:]]*$/d | grep -v "[[:digit:]]" | uniq | wc -l`

    # 获取磁盘列表
    disk_list=(`cat /proc/partitions | sort | grep -v "name" |grep -v "loop" |awk '{print $4}'| sed /^[[:space:]]*$/d | grep -v "[[:digit:]]" | uniq`)

    # 判断入参
    if [ $DISK_NUM -gt $disk_count ]; then
        log "$DISK_NUM large than $disk_count"
        return 1
    fi

    DISK=`echo ${disk_list[${DISK_NUM}]}`

    log "format_volume $DISK $PATHS"
    
    if [ -z "$DISK" ]; then
        log "parted disk is empty."
        return 1
    fi
    
    if [ -z "$PATHS" ]; then
        log "parted directory is empty."
        return 1
    fi
    
    # 如果挂载卷不存在，跳过，不报错
    volume=`fdisk -l /dev/${DISK} | grep "Disk /dev/${DISK}"`
    if [ "${volume}" = "" ]; then
        log "/dev/${DISK} is not exist,continue"
        return 1
    fi
    
    mkdir -p ${PATHS}

    parted -s /dev/${DISK} mklabel gpt
    RESULT=`parted -s /dev/${DISK} print |grep softhome |wc -l`
    if [ 0 -ne $RESULT ]; then
        log  "already parted"
    fi
    
    # 挂载磁盘，由于挂载磁盘出现过几率性失败，所以重试几次，还是不成功的话，返回失败
    formart_disk=0
    for ((k=0; k<3; k=k+1))
    do
        DISKSIZE=`parted -s /dev/${DISK} unit GB print | grep '^Disk' |grep GB | awk '{print $3}'`
        if [ -z "$DISKSIZE" ]; then
            log  "get disk size error."
            continue
        fi
        
        log "DISKSIZE=$DISKSIZE"

        DISK1=`echo ${DISK}1`

        # 先删除分区
        if [ -z "/dev/${DISK1}" ]; then
            log "/dev/${DISK1} is not exist, skip"
        else
            mount_status=`mount | grep -w /dev/${DISK1} | grep -w ${PATHS}`
            if [ "${mount_status}" != "" ]; then
                log "umount disk, /dev/${DISK1}"
                umount -l /dev/${DISK1}
            fi

            parted -s /dev/${DISK} rm 1 > /dev/null 2>&1
        fi

        # 分区
        parted -s /dev/${DISK} mkpart softhome 0G $DISKSIZE
        if [ $? -ne 0 ]; then
            log  "parted /dev/${DISK} failed, retry ..."
            continue
        fi
        
        parted -s /dev/${DISK} set 1 lvm
        if [ $? -ne 0 ]; then
            log  "set disk  number failed, /dev/${DISK}, retry ..."
            continue
        fi        

        sleep 10

        
        #创建lvm挂载
	    vgname=`echo "$2" | awk -F'/' '{print $NF}'`
        vgname="${vgname}vg"
	    lvname=`echo "$2" | awk -F'/' '{print $NF}'`
        lvname="${lvname}lv"
	    echo y | pvcreate /dev/${DISK1}
	    if [ "$?" == "0" ];then
	    	vgcreate "$vgname" /dev/${DISK1}
	    	free=`vgdisplay "$vgname" |grep "Total PE" |awk '{print $3}'`
	    	echo y | lvcreate -l "$free" -n "$lvname" "$vgname" 
	    else
	    	echo "error:your select disk is busy" 
        	exit
        fi

        lvPath=`lvdisplay "$vgname" | grep "LV Path" | awk '{print $3}'`
		#格式化
        mkfs.ext4 "${lvPath}"
        if [ $? -ne 0 ]; then
            log  "format ${lvPath} failed, retry ..."
            continue
        fi

        sleep 10

		#挂载
        mount -t ext4 ${lvPath} ${PATHS}
        if [ $? -eq 0 ]; then
            log  "mount -t ext4 ${lvPath} ${PATHS} success"
            formart_disk=1
            break
        else
            log  "mount mount -t ext4 ${lvPath} ${PATHS} failed, retry ..."
            continue
        fi

        sleep 10
        
   
    done

    cat /etc/fstab | grep -w $lvPath
    if [ 1 -ne $? ]; then
        log "$lvPath already exists !"
    else
        echo "$lvPath            ${PATHS}                    ext4       defaults        1 0" >> /etc/fstab
    fi         
    
    # 分区格式化失败，返回失败
    if [ ${formart_disk} -eq 0 ]; then
        log "format_volume ${lvPath} ${PATHS} failed, exit"
        return 1
    else
        log "format_volume ${lvPath} ${PATHS} success"
    fi


    return 0
}

#######################################################################################

mkLogDir
if [ ! -n $1 ]; then
    log "mount path is null!"
    exit 1
fi
# 格式化硬盘
partion $1 $2

exit $?
