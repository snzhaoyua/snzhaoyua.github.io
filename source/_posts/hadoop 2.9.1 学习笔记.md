---
title: hadoop 2.9.1 学习笔记
categories:  
- 备忘
- 技术
tags: 
- Hadoop
- BigData
---

# hadoop 学习笔记

HDFS读写流程
=====================


HDFS文件权限
=====================


安全模式
=====================

注意事项
=======
JDK 版本应该使用 1.8，JDK 10 遇到启动过程中 warning 并且 datanode 无法启动的问题。

集群安装
=====================


最小配置文件（hadoop 2.9.1）
--------------------------------------------
core-site.xml
```xml
<configuration>
        <property>
                <name>fs.defaultFS</name>
                <value>hdfs://linux-1:8020/</value>
                <description>NameNode URI</description>
        </property>

        <property>
                <name>io.file.buffer.size</name>
                <value>131072</value>
                <description>Buffer size</description>
        </property>
</configuration>
```

hdfs-site.xml
```xml
<configuration>
        <property>
                <name>dfs.secondary.http.address</name>
                <value>linux-2:50090</value>
        </property>
        <property>
                <name>dfs.http.address</name>
                <value>linux-1:50070</value>
        </property>
        <property>
                <name>dfs.namenode.name.dir</name>
                <value>file:///opt/hdfs/namenode</value>
                <description>NameNode directory for namespace and transaction logs storage.</description>
        </property>

        <property>
                <name>dfs.namenode.edits.dir</name>
                <value>file:///opt/hdfs/namenode</value>
                <description>DFS name node should store the transaction (edits) file.</description>
        </property>

        <property>
                <name>dfs.datanode.data.dir</name>
                <value>file:///opt/hdfs/datanode</value>
                <description>DataNode directory</description>
        </property>

        <property>
                <name>dfs.namenode.checkpoint.dir</name>
                <value>file:///opt/hdfs/secondarynamenode</value>
                <description>Secondary Namenode directory</description>
        </property>

        <property>
                <name>dfs.namenode.edits.dir</name>
                <value>file:///opt/hdfs/namenode</value>
                <description>DFS name node should store the transaction (edits) file.</description>
        </property>

        <property>
                <name>dfs.datanode.data.dir</name>
                <value>file:///opt/hdfs/datanode</value>
                <description>DataNode directory</description>
        </property>

        <property>
                <name>dfs.namenode.checkpoint.dir</name>
                <value>file:///opt/hdfs/secondarynamenode</value>
                <description>Secondary Namenode directory</description>
        </property>

        <property>
                <name>dfs.namenode.checkpoint.edits.dir</name>
                <value>file:///opt/hdfs/secondarynamenode</value>
                <description>DFS secondary name node should store the temporary edits to merge.</description>
        </property>

        <property>
                <name>dfs.namenode.checkpoint.period</name>
                <value>7200</value>
                <description>The number of seconds between two periodic checkpoints.</description>
        </property>

        <property>
                <name>dfs.namenode.checkpoint.txns</name>
                <value>1000000</value>
                <description>SecondaryNode or CheckpointNode will create a checkpoint of namespace every 1000000 transactions</description>
        </property>

        <property>
                <name>dfs.replication</name>
                <value>2</value>
        </property>

        <property>
                <name>dfs.permissions</name>
                <value>false</value>
        </property>

        <property>
                <name>dfs.datanode.use.datanode.hostname</name>
                <value>true</value>
        </property>

        <property>
                <name>dfs.namenode.datanode.registration.ip-hostname-check</name>
                <value>true</value>
        </property>
</configuration>
```


mapred-site.xml
```xml
<configuration>
        <property>
                <name>mapreduce.framework.name</name>
                <value>yarn</value>
                <description>MapReduce framework name</description>
        </property>

        <property>
                <name>mapreduce.jobhistory.address</name>
                <value>linux-1:10020</value>
                <description>Default port is 10020.</description>
        </property>

        <property>
                <name>mapreduce.jobhistory.webapp.address</name>
                <value>linux-1:19888</value>
                <description>Default port is 19888.</description>
        </property>

        <property>
                <name>mapreduce.jobhistory.intermediate-done-dir</name>
                <value>/mr-history/tmp</value>
                <description>Directory where history files are written by MapReduce jobs.</description>
        </property>

        <property>
                <name>mapreduce.jobhistory.done-dir</name>
                <value>/mr-history/done</value>
                <description>Directory where history files are managed by the MR JobHistory Server.</description>
        </property>
</configuration>
```

yarn-site.xml
```xml
<configuration>

<!-- Site specific YARN configuration properties -->
    <property>
            <name>yarn.nodemanager.aux-services</name>
            <value>mapreduce_shuffle</value>
            <description>Yarn Node Manager Aux Service</description>
    </property>

    <property>
            <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
            <value>org.apache.hadoop.mapred.ShuffleHandler</value>
    </property>

    <property>
            <name>yarn.nodemanager.local-dirs</name>
            <value>file:///opt/yarn/local</value>
    </property>

    <property>
            <name>yarn.nodemanager.log-dirs</name>
            <value>file:///opt/yarn/logs</value>
    </property>

</configuration>

```



hadoop-env.sh
```shell
##update this line
export JAVA_HOME=/opt/jdk1.8.0_181
##add this to last
export HADOOP_HOME=/opt/hadoop-2.9.1
export HADOOP_CONF_DIR=/opt/hadoop-2.9.1/etc/hadoop
export HADOOP_LOG_DIR=${HADOOP_HOME}/logs
```

/etc/profile
```shell
export HADOOP_INSTALL=/opt/hadoop-2.9.1  
export PATH=$PATH:$HADOOP_INSTALL/bin  
export PATH=$PATH:$HADOOP_INSTALL/sbin  
export HADOOP_MAPRED_HOME=$HADOOP_INSTALL  
export HADOOP_COMMON_HOME=$HADOOP_INSTALL  
export HADOOP_HDFS_HOME=$HADOOP_INSTALL  
export YARN_HOME=$HADOOP_INSTALL
export HADOOP_CONF_DIR=$HADOOP_INSTALL/etc/hadoop
export HADOOP_PREFIX=$HADOOP_INSTALL
```


启动命令
=======
start-all.sh (废弃)

NameNode
------------------
start-dfs.sh  
http://192.168.44.128:50070/dfshealth.html#tab-overview

ResourceManager
------------------
start-yarn.sh  
http://192.168.44.128:8088/cluster

JobHistoryServer
------------------
`mr-jobhistory-daemon.sh --config /opt/hadoop-2.9.1/etc/hadoop start historyserver  `
http://192.168.44.128:19888/jobhistory

参考
====
> http://gaurav3ansal.blogspot.com/2018/06/install-hadoop-291-pseudo-distributed.html