#!/bin/bash
# FileName:      readFileToSsdb1.sh
# Description:   从文件中读取每一行ssdb/redis的参数数据，然后拼接成完整命令写入到ssdb/redis中。
# Simple Usage:  ./readFileToSsdb1.sh
# (c) 2020.08.09 vfhky https://typecodes.com
# https://github.com/vfhky/shell-tools/blob/master/cache/readFileToSsdb1.sh

cat ssdbArgs.txt | while read line
do
    echo ${line}
    # ssdb: zset name key score
    echo "zset pk_all_rank_test_20200809 ${line}" | ssdb-cli -h 101.10.118.115 -p 28888
    # redis: ZADD name SCORE1 KEY1
    # echo "zset pk_all_rank_test_20200809 ${line}" | redis-cli -h 101.10.118.115 -p 28888
done
