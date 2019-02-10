---
title: Hive 2.3.3 安装常见问题
categories:  
- 备忘
- 技术
tags: 
- Hive
- BigData
---

remote 模式最小配置
=================
```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
<property>
<name>javax.jdo.option.ConnectionURL</name>
<value>jdbc:mysql://192.168.47.128:3306/hive?createDatabaseIfNotExist=true</value>
</property>
<property>
<name>javax.jdo.option.ConnectionDriverName</name>
<value>com.mysql.jdbc.Driver</value>
</property>
<property>
<name>javax.jdo.option.ConnectionUserName</name>
<value>root</value>
</property>
<property>
<name>javax.jdo.option.ConnectionPassword</name>
<value>km717070</value>
</property>
</configuration>
```         
安装问题
=======

1. remote 模式报错 Java.lang.RuntimeException: Unable to instantiate org.apache.hadoop.hive.ql.metadata.SessionHiveMetaStoreClient
解决：hive 需要先 `hive --service metastore` 先启动 thrift server，才能访问 mysql
参考：[官方手册：Hive Metastore 配置](https://cwiki.apache.org/confluence/display/Hive/AdminManual+MetastoreAdmin#AdminManualMetastoreAdmin-RemoteMetastoreDatabase)
理解：mysql 为 metastore 的 database， Thrift Server 为 metastore 的服务器

2. hive --service metastore 启动报错 Unable to open a test connection to the given database
解决：mysql 的配置有问题  
场景1：mysql 只允许本地访问  
场景2：mysql 白名单未添加相应机器  
参考：  
> [如何确定 mysql 使用的配置文件](/2018/10/13/)  
> [mysql 访问常见问题](/2018/10/13/mysql 访问常见问题)  
> [Unable to open a test connection to the given database](http://hadooptutorial.info/unable-open-test-connection-given-database/)  

1. 报错 Version infomation not found in metastore
原因：hive 0.12 以后版本会验证 metastore version，metastore 中无该信息，因此无法访问
解决：schematool -dbType mysql -initSchema 刷库

4. 警告 ssl 连接 mysql 的信息
jdbc 连接串添加 &useSSL=false 即可，注意在 xml 中的转义（写成 `&amp;useSSL=false`）。

5. hive on mr is deprecated in hive 2, consider using a different execution engine like spark. or using a hive 1.x version  
[hive spark tez 对比](https://www.slideshare.net/MichTalebzadeh1/query-engines-for-hive-mr-spark-tez-with-llap-considerations)