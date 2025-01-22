#!/usr/bin/python
# -*-coding:utf-8 -*-
#
# python2.7 演示使用 mysql 和 redis
# (c) 2025.01 vfhky https://typecodes.com/mysql/mysql_redis_sample.html
# https://github.com/vfhky/shell-tools/blob/master/mysql/mysql_redis_sample.py

import redis
import MySQLdb
import sys

mlen = len(sys.argv)

if mlen != 2:
    print "wrong input. please input uid"
    sys.exit(0)


def del_user_site_inner_notify(conn, uid):
    key = "test_" + str(uid)
    print "del redis key=" + key
    conn.delete(key)

def update_user(dbCur, redisConn, uid):
    # mysql
    table_name = "test_" + str(uid)
    expire_date = expireDate + " 23:59:59"
    sql = ("update " + table_name + " set user_name='typcodes.com' where uid= " + str(uid))
    print "execute sql=" + sql

    dbCur.execute(sql)
    dbCur.connection.commit()

    # redis
    del_user_site_inner_notify(redisConn, uid)




def dbInit():
    conn = MySQLdb.connect(host="101.1.1.1",
                           port=3066,
                           user="user",
                           passwd="passwd",
                           db="dbname",
                           charset="utf8")
    return conn

def dbClose(dbCon):
    dbCon.cursor().close()
    dbCon.commit()
    dbCon.close()


def redisInit():
    pool = redis.ConnectionPool(host='101.1.1.1', port=3012)
    return redis.Redis(connection_pool=pool)

def redisClose(conn):
    conn.connection_pool.disconnect()


def main():
    uid = int(sys.argv[1])

    dbCon = dbInit()
    redisConn = redisInit()
    try:
        update_user(dbCon.cursor(), uid)
        print "========success=========="
    finally:
        dbClose(dbCon)
        redisClose(redisConn)

if __name__ == '__main__':
    main()
