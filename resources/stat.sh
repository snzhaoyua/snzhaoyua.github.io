#!/usr/bin/env bash


totalSql="SELECT IFNULL(SUM(TABLE_ROWS),0) as t_rows_sum FROM information_schema.tables WHERE TABLE_SCHEMA NOT IN ('mysql','information_schema','performance_schema','sys');"

eachTableSql="SELECT CONCAT(TABLE_SCHEMA,'.',TABLE_NAME) AS table_name, IFNULL(TABLE_ROWS,0) as table_rows FROM information_schema.tables WHERE TABLE_SCHEMA NOT IN ('mysql','information_schema','performance_schema','sys') ORDER BY 2;"


mysql -udbAdmin -pabcd1234 -A --skip-column-names -e "${totalSql}" > /home/mysql/temp/tableRowsCount
mysql -udbAdmin -pabcd1234 -A --skip-column-names -e "${eachTableSql}" >> /home/mysql/temp/tableRowsCount
