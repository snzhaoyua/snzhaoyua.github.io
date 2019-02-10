---
title: 使用 Ambari 安装 HDP 集群
categories: 
- 备忘
- 技术
tags: 
- ambari
- BigData
---

请先参考 [CentOs 7 安装 apache-ambari](/2018/10/13/centos 7 安装 apache-ambari/) 获得一台 ambari 服务器。

HDP 并不是 hadoop 的辅音简称，而是 Hortonworks 的产品 [Hortonworks Data Platform](https://community.hortonworks.com/questions/89821/difference-between-apache-hadoop-and-hdp.html) 的简称，是包含 Hadoop 在内的一揽子解决方案。

## 前置要求：
3-4台 CentOS 7 机器，其中一台机器必须安装 Ambari 服务。教程参考[centos 7 安装 apache-ambari](/2018/10/13/centos 7 安装 apache-ambari/)。安装 master 和 slave 的节点机器，内存最好不要小于 5G。

## 安装部件：

如前所述，此次安装包含如下服务（请按需安装）：

服务|版本|说明
----|----|----
HDFS|2.7.3|Apache Hadoop 分布式文件系统
YARN + MapReduce2|2.7.3|Apache Hadoop 下一代 MapReduce(YARN)
Tez|0.7.0|Tez 是运行在 YARN 之上的下一代 Hadoop 查询处理框架
Hive|1.2.1000|支持即席查询与大数据量分析和存储管理服务的数据仓库系统
HBase|1.1.2|非关系型分布式数据库，包括 Phoenix，一个为低延迟应用开发的高性能 sql 扩展
Pig|0.16.0|分析大数据量的脚本平台
Sqoop|1.4.6|在 Apache Hadoop 和 其它结构化的数据存储位置例如关系数据库 之间批量传递数据的工具
Oozie|4.2.0|Apache Hadoop 的工作引擎之一，另一个是 Azkaban。负责工作流的协调和执行。会按照一个可选的 Oozie Web 客户端，依赖此也会安装 ExtJS 库
Zookeeper|3.4.6|高可用的分布式协调服务
Falcon|0.10.0|数据管理和处理平台
Storm|1.1.0|Apache Hadoop 流处理框架[Storm 介绍](https://www.cnblogs.com/Jack47/p/storm_intro-1.html)
Flume|1.5.2|收集，聚合和移动大量流式数据到 HDFS 的分布式服务
Accumulo|1.7.0|高可靠，性能和伸缩性的 Key/Value 存储[各种KV工具对比]https://kkovacs.eu/cassandra-vs-mongodb-vs-couchdb-vs-redis)
Ambari Infra|0.1.0|Ambari 管理的部件所使用的核心共享服务
Ambari Metrics|0.1.0|Ambari 集群性能监控工具
Atlas|0.8.0|元数据管理平台
Kafka|1.0.0|高吞吐量的分布式消息系统
Knox|0.12.0|一个 rest 类型的认证系统，可提供单点登录认证
Log Search(未安装)|0.5.0|日志聚合，分析，可视化
SmartSense|1.4.5.2.6.2.2-1|一款不得不装的 Hortonworks 增值服务，集群诊断功能
Spark|1.6.3|快速的大规模数据处理引擎
Spark2|2.3.0|[spark spark2 对比](https://stackoverflow.com/questions/40168779/apache-spark-vs-apache-spark-2)
Zeppelin NoteBook|0.7.3|Web 界面的数据分析系统，可以使用 sql 和 scala 等
Druid|0.10.1|快速的列存储分布式系统
Mahout|0.9.0|Apache 开源机器学习算法库，提供协作筛选（CF，推荐算法），聚类（clustering），分类(classification)实现
Slider|0.92.0|部署，管理与监控 YARN 上的应用程序
Superset|0.15.0|Airbnb 的开源可视化的数据平台


#### 安装注意事项
###### 在 *确认主机 Confirm Hosts* 阶段，即使你的 openssl 是最新的，还是可能会报如下错误：

```txt
NetUtil.py:96 EOF occured in violation of protocol (_ssl.c:579)
和
SSLError: Failed to connect.Please check openssl library version.
```

此时需要在每一台节点上加入以下配置：

```shell
vi /etc/ambari-agent/conf/ambari-agent.ini

[security] ## 在此部分加入以下一行
force_https_protocol=PROTOCOL_TLSv1_2
```

**在公司，不方便上图，回家继续更新。**