-- master

CREATE USER slave1 IDENTIFIED BY '123456';
GRANT SELECT, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'slave1'@'%';
GRANT ALL PRIVILEGES ON *.* TO 'slave1'@'%' ;

# 刷新权限
FLUSH PRIVILEGES;

# 获取主数据库 binlog 日志状态，主要是确定日志的文件名以及从数据库开始读取的日志位置. 
# 记录一下File 和Position, 用于在从服务器配置连接的主服务器时的部分参数
SHOW MASTER  STATUS; 

-- INSERT INTO test VALUES(33333333333)


-- slave1
# 首先停止数据同步相关的线程： slave I/O 线程和 slave SQL 线程
STOP SLAVE;

# 为了避免可能发生的错误，直接重置客户端
RESET SLAVE;

#设置主从同步隶属关系
# mysql_master 为主数据库的容器服务名称，如果是非容器部署，就填写主服务器的ip
# MASTER_LOG_FILE=binlog_filename.000005 为主数据库binlog的文件名
# MASTER_LOG_POS=156 为binlog日志开始同步时的位置
# Binlog_Do_DB=db_ginskeleton  需要同步的数据库
# Binlog_Ignore_DB=mysql,test  指定忽略同步的数据库

SET @binlog_filename='binlog.000003'  ;
SET @binlog_pos=157  ;
CHANGE MASTER TO MASTER_HOST='master',MASTER_PORT=3306,MASTER_USER='slave1',MASTER_PASSWORD='123456',MASTER_LOG_FILE='binlog.000002',MASTER_LOG_POS=157;

#启动slaver 服务
START SLAVE; 


# 查看从数据库的状态
SHOW SLAVE STATUS;
