---
title: mysql knowledge
categories:  
- 备忘
- 技术
tags: 
- mysql
---


第一部分 MySQL篇	


### 1 MySQL源代码入门	
MySQL源代码的组织结构	
Linux下的编译	
安装MySQL库	
MySQL 5.7权限处理	

### 2 MySQL启动过程	

### 3 连接的生命与使命	
用户连接线程创建	
MySQL处理请求	
总结	

### 4 MySQL表对象缓存	
表结构的实现原理	
涉及的参数变量	
优缺点总结	
存在的问题	
5 InnoDB初探	

### InnoDB的源代码目录结构	
InnoDB存储引擎文件组织	
InnoDB体系结构	
InnoDB存储引擎启动与关闭	
InnoDB 存储引擎的启动	
InnoDB存储引擎的关闭	

### 6 InnoDB数据字典	
背景	
系统表结构	
字典表加载	
Rowid管理	
总结	

### 7 InnoDB数据存储结构	
表空间文件组成结构	
段	
簇	
页面	
段、簇、页面组织结构	

### 8 InnoDB索引实现原理	
背景	
B 树及B树的区别	
索引的设计	
聚簇索引和二级索引	
二级索引指针	
神奇的B 树网络	
InnoDB索引的插入过程	
一个页面至少要存储几条记录	
页面结构管理	
文件管理头信息	
页面头信息	
最小记录和最大记录	
页面数据空间管理	
经典的槽管理	
页面尾部	
页面重组	
索引页面的回收	

### 9 InnoDB记录格式	
背景	
从源码入手了解行格式	
总结	

### 10 揭秘独特的两次写	
单一页面刷盘	
批量页面刷盘	
两次写组织结构	
批量刷盘两次写实现原理	
两次写的作用	
发散思维	
总结	

### 11 InnoDB日志管理机制	
InnoDB Buffer Pool	
REDO LOG日志文件管理的用途	
MTR InnoDB物理事务	
日志的意义	
日志记录格式	
日志刷盘时机	
REDO日志恢复	
数据库回滚	
数据库UNDO段管理	
数据库UNDO日志记录格式	
回滚时刻	
总结	

### 12 MySQL 5.7中崭新的MySQL sys Schema	
Performance Schema的改进	
sys Schema介绍	
sys Schema视图摘要	
sys Schema重点视图与应用场景	
使用风险	
总结	

### 13 方便的MySQL GTID	
GTID 相关概念	
什么是GTID	
GTID集合	
GTID生命周期	
GTID的维护	
gtid_executed表	
gtid_executed表压缩	
GTID搭建主从	
搭建主从时，需要注意的MySQL参数	
开启GTID	
搭建主从	
使用GTID案例总结	
如何跳过一个GTID	
利用GTID模式快速改变主从复制关系	
在线将传统模式复制改为GTID模式复制	
在线将GTID模式复制改为传统模式复制	
GTID的限制	

### 14 MySQL半同步复制	
半同步特性	
半同步主库端	
半同步从库端	
半同步实现	
插件安装	
半同步自动开关	

### 15 MySQL 5.7多线程复制原理	
背景	
行之有效的延迟优化方法	
MySQL 5.6的多线程复制	
MySQL 5.7的多线程复制	
ordered commit	
多线程复制分发原理	
异常故障恢复	

### 16 大量MySQL表导致服务变慢的问题	
背景	
问题分析	
案例解决	
总结	

### 17 MySQL快速删除大表	
背景	
问题分析	
案例解决	
发散思维	
总结	

### 18 两条不同的插入语句导致的死锁	
背景	
问题分析	
发散思维	
总结	

### 19 MySQL在并发删除同一行数据时导致死锁的分析	
背景	
问题分析	
发散思维	
总结	

### 20 参数SQL_SLAVE_SKIP_COUNTER的奥秘	

### 21 Binlog中的时间戳	
背景	
问题分析	
发散思维	
事务中的事件顺序	
问题延伸	
show processlist中的Time	
总结	

### 22 InnoDB中Rowid对Binlog的影响	
背景	
问题分析	
总结	

### 23 MySQL备份：Percona XtraBackup的原理与实践	
备份背景及类型	
认识Percona XtraBackup	
XtraBackup的工作流程	
XtraBackup的备份原理	
XtraBackup 需要的权限	
innobackupex常用的备份选项说明	
XtraBackup备份实践	
全量备份	
增量备份	
并行备份	
其他备份	
案例实践与心得	
建议与提醒	

### 24 MySQL分库分表	
分库分表的种类	
分库分表的原则	
分库分表实现	
数据库层的实现	
业务层的实现	

### 25 MySQL数据安全	
单机安全	
集群安全	
备份安全	
MySQL实例安全保证	
Double Write	
REDO LOG	
MySQL集群安全保证	
传统的主从模式如何保证数据库安全	
Semi_Sync Replication方式的复制	
MySQL集群化如何保证数据库安全	
总结	

### 26 MySQL 性能拾遗	
适当的数据文件大小	
碎片空洞问题	
设计问题	
合理设计表结构	
冗余存储	
拆分存储	
重复存储	
特别提醒	
正确使用索引	
MySQL系统参数	
内存和CPU	
磁盘的革命	
云中漫步	
总结	

### 27 MySQL Group Replication	
Group Replication概述	
组的概念	
多主复制	
单独的通信机制	
Group Replication服务模式	
单主模式	
多主模式	
服务模式的配置	
Binlog Event的多线程执行	
group_replication_applier通道	
基于主键的并行执行	
搭建Group Replication复制环境	
MySQL的参数设置	
Group Replication插件的使用	
Group Replication插件的基本参数设置	
Group Replication的数据库用户	
Group Replication组初始化	
新成员加入组	
Group Replication的高可用性	
组内成员数量的变化	
强制移除故障成员	
Group Replication的监控	
Group Replication的基本原理	
状态机复制	
分布式的状态机复制	
分布式的高可用数据库	
深入理解Group Replication中事务的执行过程	
本地事务控制模块	
成员间的通信模块	
全局事务认证模块	
异地事务执行模块	
事务流程的总结	
深入理解成员加入组的过程	
组视图	
加入组时视图的切换	
View_change_log_event	
恢复	

### 28 MySQL Document Store面面观	
新的JSON数据类型和JSON函数	
JSON数据类型	
JSON函数详解	
JSON函数的运用	
MySQL X Plugin 和 X Protocol	
支持NoSQL所做的努力	
安装MySQL X Plugin	
MySQL Shell	
安装MySQL Shell	
运行MySQL Shell	
在MySQL Shell中操作JSON文档	
用脚本执行MySQL Shell	
X DevAPI	
总结	
参考资料	
第二部分 Galera篇	

### 29 Galera Cluster的设计与实现	
Galera Cluster的优点	
Galera的引入	
Galera接口	
总结	

### 30 Galera 参数解析	
状态参数	
变量参数	

### 31 Galera的验证方法	
Binlog与Galera的关系	
验证方法	

### 32 Galera的消息传送	

### 33 GCache实现原理	
配置参数	
实现原理	
发散思维	

### 34 大话SST/IST细节	
初始化节点环境	
连接到集群并且做SST/IST	
如何提供增量数据	
总结	

### 35 Donor/Desynced详解	
实现方式	
意义何在	
问答环节	

### 36 Galera的并发控制机制	
数据复制	
写集验证	
写集APPLY	
事务Commit	

### 37 Galera的流量控制	
流量控制的定义	
流量控制的实现原理及影响	
两个问题	

### 38 Galera Cluster影响单节点执行效率的因素	
单点验证	
并发控制	
等待GTID	
总结	

### 39 grastate.dat文件揭秘	
引子	
分析研究	
总结	

### 40 Galera Cluster从库的转移	
没有开启Server级GTID的情况	
开启了GTID（server级）的情况	
总结	

### 41 Galera Cluster节点与其从库的随意转换	
背景	
从节点向PXC节点的转换	
PXC节点向异步从节点的转换	

### 42 业务更新慢，不是由Galera引起的	

### 43 在线改表引发的Galera Cluster集群死锁	
背景	
用Binlog来代替触发器	
表名交换	
Galera Cluster中的问题	
一个有趣的实验	
解决方案	
总结	
第三部分 Inception篇	

### 44 Inception诞生记	
关于SQL审核	
半自动化方法	
人肉法	
不满现状的追求	
何谓Inception	

### 45 Inception安装与使用	
下载和编译	
启动配置	
线上配置需求	
需要额外注意的点	
使用方法	
举例说明	
环境变量的设置	

### 46 支持选项	
选项说明	
DDL与DML语句分离	
小技巧	

### 47 Inception的备份回滚	
备份存储架构	
备份所需条件	

### 48 审核规范	
支持的语句类型	
公共检查项	
插入语句检查项	
更新、删除语句检查项	
表属性检查项	
列属性检查项	
索引属性检查项	
修改表语句检查项	
总结	

### 49 参数变量	
语法和变量	
注意事
