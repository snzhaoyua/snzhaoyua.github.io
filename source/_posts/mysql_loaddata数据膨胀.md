---
title: MySQL loaddata 数据膨胀（mysql 后台文件大小分析）
categories:
- 备忘
- 技术
tags: 
- MySQL
---

# 1. 发现问题
100w 100字段数据 后台膨胀系数较大。
用膨胀系数表示load data后mysql后台 表名.ibd 文件的大小与所 load 的 data.xdr 文件的比值。
膨胀系数(50f100w)代表使用了50个字段100w行的数据进行测试。

# 2. 分解问题

## 2.1 是否是数据量较大，导致膨胀系数较大？
构造 10f10w 和 10f100w 进行对比，排除单纯因数据量导致膨胀的推测。

| 数据模型（字段数）       | 数据模型（行数） | 数据文件大小（MB） | load 时长(s) | 表文件大小(MB) | 单次导入增加 | 字段类型    |
|-----------------|----------|------------|------------|-----------|--------|---------|
| 10              | 10w      | 58.9       | 3.02       | 76        | 76     | "3 int, |
| 3 double(20,2), |
| 4 VARCHAR(256)  |
| "               |
| 10              | 100w     | 592        | 33.96      | 688       | 688    | "3 int, |
| 3 double(20,2), |
| 4 VARCHAR(256)  |
| "               |

## 2.2 是否是因字段数不同，导致膨胀系数较大？

### 数据模型
```sql
create table loadtest10f(
    record_001 VARCHAR(256),
    record_002 VARCHAR(256),
    record_003 VARCHAR(256),
    record_004 VARCHAR(256),
    record_005 VARCHAR(256),
    record_006 VARCHAR(256),
    record_007 VARCHAR(256),
    record_008 VARCHAR(256),
    record_009 VARCHAR(256),
    record_010 VARCHAR(256),
    ....
)
```

因构造数据工具内存限制，100字段最多构造出2w行数据，为了方便对比，以下所有数据都构造2w行；
因mysql 默认row size为65535，构造的数据模型为varchar(256)，且服务器采用utf8(每个字符3个字节)，所以最多构造到65535/256/3个字段；

构造同样是2w行数据的 10f,20f,50f,60f,70f,80f,85f 等数据进行测试，结果如下：

| 数据模型（字段数） | 数据模型（行数） | 数据文件大小（MB） | load 时长(s) | 表文件大小(MB) | 字段类型         | 最大行大小 | B+树高度 | 膨胀系数        |
|-----------|----------|------------|------------|-----------|--------------|-------|-------|-------------|
| 10        | 20000    | 15         | 0.63       | 26        | varchar(256) | 7680  | 1     | 1.733333333 |
| 20        | 20000    | 29         | 1.04       | 42        | varchar(256) | 15360 | 1     | 1.448275862 |
| 30        | 20000    | 44         | 1.63       | 63        | varchar(256) | 23040 | 1     | 1.431818182 |
| 50        | 20000    | 72         | 3.07       | 110       | varchar(256) | 38400 | 1     | 1.527777778 |
| 60        | 20000    | 87         | 12.88      | 680       | varchar(256) | 46080 | 3     | 7.816091954 |
| 70        | 20000    | 101        | 35.61      | 1921      | varchar(256) | 53760 | 3     | 19.01980198 |
| 80        | 20000    | 115        | 61.87      | 3280      | varchar(256) | 61440 | 3     | 28.52173913 |
| 85        | 20000    | 123        | 70.04      | 3985      | varchar(256) | 65280 | 3     | 32.39837398 |
| 100       | 20000    | 144        |            |           | varchar(256) |


### 说明
数据显示，字段在50f左右开始，膨胀系数曲线较之前更为陡峭，该变化记为 d1；
在50f之后曲线再次平缓，增长速度小于 d1.

### 分析
几点说明：
1. innodb 默认 page size 为 16834.
```sql
mysql> show variables like 'innodb_page_size';
+------------------+-------+
| Variable_name    | Value |
+------------------+-------+
| innodb_page_size | 16384 |
+------------------+-------+
1 row in set (0.00 sec)
```

2. innodb 采用B+Tree数据结构，查询这几个构造的数据表，其根节点页起始页码为3：
```sql
mysql> SELECT
    -> b.name, a.name, index_id, type, a.space, a.PAGE_NO
    -> FROM
    -> information_schema.INNODB_SYS_INDEXES a,
    -> information_schema.INNODB_SYS_TABLES b
    -> WHERE
    -> a.table_id = b.table_id AND a.space <> 0 AND b.name like '%loadtest%';
+-----------------------+-----------------+----------+------+-------+---------+
| name                  | name            | index_id | type | space | PAGE_NO |
+-----------------------+-----------------+----------+------+-------+---------+
| test/loadtest100f100w | GEN_CLUST_INDEX |    30333 |    1 | 16650 |       3 |
| test/loadtest10f      | GEN_CLUST_INDEX |    30334 |    1 | 16651 |       3 |
| test/loadtest10f100w  | GEN_CLUST_INDEX |    30329 |    1 | 16646 |       3 |
| test/loadtest10f10w   | GEN_CLUST_INDEX |    30328 |    1 | 16645 |       3 |
| test/loadtest20f      | GEN_CLUST_INDEX |    30335 |    1 | 16652 |       3 |
| test/loadtest20f100w  | GEN_CLUST_INDEX |    30330 |    1 | 16647 |       3 |
| test/loadtest30f      | GEN_CLUST_INDEX |    30336 |    1 | 16653 |       3 |
| test/loadtest50f      | GEN_CLUST_INDEX |    30337 |    1 | 16654 |       3 |
| test/loadtest50f100w  | GEN_CLUST_INDEX |    30331 |    1 | 16648 |       3 |
| test/loadtest60f      | GEN_CLUST_INDEX |    30340 |    1 | 16657 |       3 |
| test/loadtest70f      | GEN_CLUST_INDEX |    30341 |    1 | 16658 |       3 |
| test/loadtest80f      | GEN_CLUST_INDEX |    30338 |    1 | 16655 |       3 |
| test/loadtest85f      | GEN_CLUST_INDEX |    30342 |    1 | 16659 |       3 |
+-----------------------+-----------------+----------+------+-------+---------+
13 rows in set (0.00 sec)
```

3. 查询其 pagelevel （根页偏移64字节的前2位，即16834*3+64=49216）
```bash
SHA1000130993:/usr/local/mysql/data/test # hexdump -s 49216 -n 10 loadtest10f.ibd
000c040 0000 0000 0000 0000 7e76
000c04a
SHA1000130993:/usr/local/mysql/data/test # hexdump -s 49216 -n 10 loadtest20f.ibd
000c040 0000 0000 0000 0000 7f76
000c04a
SHA1000130993:/usr/local/mysql/data/test # hexdump -s 49216 -n 10 loadtest30f.ibd
000c040 0000 0000 0000 0000 8076
000c04a
SHA1000130993:/usr/local/mysql/data/test # hexdump -s 49216 -n 10 loadtest50f.ibd
000c040 0000 0000 0000 0000 8176
000c04a
SHA1000130993:/usr/local/mysql/data/test # hexdump -s 49216 -n 10 loadtest60f.ibd
000c040 0200 0000 0000 0000 8476
000c04a
SHA1000130993:/usr/local/mysql/data/test # hexdump -s 49216 -n 10 loadtest70f.ibd
000c040 0200 0000 0000 0000 8576
000c04a
SHA1000130993:/usr/local/mysql/data/test # hexdump -s 49216 -n 10 loadtest80f.ibd
000c040 0200 0000 0000 0000 8276
000c04a
SHA1000130993:/usr/local/mysql/data/test # hexdump -s 49216 -n 10 loadtest85f.ibd
000c040 0200 0000 0000 0000 8676
000c04a
```

4. 获取 page level 和 B+Tree 高度
由于本人测试机器字节序为小端，所以000c040 0200十六进制字节实际值为000c040 0002，即2.
从上一步骤得出50f以后的表pagelevel为2,50f之前pagelevel为0.
所以50f以后的表B+Tree高度为page level+1=3.
B+Tree高度一般为1-3，很少有4。3 属于较高的高度，怀疑数据全为索引所占。

5. 获取index所占page的粗略信息。由于本文测试数据未建索引，所以默认索引为GEN_CLUST_INDEX。主键、聚簇索引，本身即是数据，可以看到磁盘基本都是索引占据。

```sql
mysql> SELECT
    -> table_name,
    ->        sum(stat_value) pages,
    ->        index_name,
    ->        sum(stat_value) * @@innodb_page_size size
    -> FROM
    ->        mysql.innodb_index_stats
    -> WHERE
    ->            table_name like '%load%'
    ->        AND database_name = 'test'
    ->        AND stat_description = 'Number of pages in the index'
    -> GROUP BY
    ->        table_name,index_name;
+------------------+--------+-----------------+-------------+
| table_name       | pages  | index_name      | size        |
+------------------+--------+-----------------+-------------+
| loadtest100f100w | 785472 | GEN_CLUST_INDEX | 12869173248 |
| loadtest10f      |   1059 | GEN_CLUST_INDEX |    17350656 |
| loadtest10f100w  |  42112 | GEN_CLUST_INDEX |   689963008 |
| loadtest10f10w   |   4327 | GEN_CLUST_INDEX |    70893568 |
| loadtest20f      |   2084 | GEN_CLUST_INDEX |    34144256 |
| loadtest20f100w  |  85568 | GEN_CLUST_INDEX |  1401946112 |
| loadtest30f      |   3366 | GEN_CLUST_INDEX |    55148544 |
| loadtest50f      |   6121 | GEN_CLUST_INDEX |   100286464 |
| loadtest50f100w  |  99456 | GEN_CLUST_INDEX |  1629487104 |
| loadtest60f      |  40425 | GEN_CLUST_INDEX |   662323200 |
| loadtest70f      | 115114 | GEN_CLUST_INDEX |  1886027776 |
| loadtest80f      | 196778 | GEN_CLUST_INDEX |  3224010752 |
| loadtest85f      | 239466 | GEN_CLUST_INDEX |  3923410944 |
+------------------+--------+-----------------+-------------+
```


