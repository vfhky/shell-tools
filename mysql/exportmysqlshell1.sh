#!shell
#!/bin/bash
# FileName:      exportmysqlshell1.sh
# Description:   使用shell脚本导出MySql月表数据到EXCEL中
# Simple Usage:  sh exportmysqlshell1.sh
# (c) 2020.08.01 vfhky https://typecodes.com/linux/exportmysqlshell1.html
# https://github.com/vfhky/shell-tools/blob/master/mysql/exportmysqlshell1.sh

if [[ $# -ne 2 ]]; then
	echo "usage: sudo $0 startTimeStamp endTimeStamp"
	exit 0
fi

startTimeStamp=$1
endTimeStamp=$2

# 简单校验合法性
if [[ "${startTimeStamp}" -ge "${endTimeStamp}" ]]; then
    echo "${startTimeStamp} >= ${endTimeStamp}."
    exit 1
fi

# 获得月表后缀
startYearMonth=$(date -d @"${startTimeStamp}"  "+%Y%m")
endYearMonth=$(date -d @"${endTimeStamp}"  "+%Y%m")
if [[ "${startYearMonth}" -ne "${endYearMonth}" ]]; then
    echo "${startYearMonth} is not equalt to ${endYearMonth}."
    exit 2
fi

curDateTime=$(date "+%Y-%m-%d %H:%M:%S")
timeStamp=$(date -d "$current" +%s)

dstFilePrefix="gather_rcd_"${startTimeStamp}"_"${endTimeStamp}"_"${timeStamp}
dstFile=${dstFilePrefix}"_gbk.csv"
dstFileUtf8Txt=${dstFilePrefix}"_utf8.txt"
dstFileUtf8Csv=${dstFilePrefix}"_utf8.csv"
echo ${curDateTime}","${timeStamp}","${dstFile}

# mysql命令导出查询结果到txt文件中
mysql -h113.16.111.17 -P3301 -utest_user -p12345678 activity --default-character-set=utf8 -A -e "SELECT uid, FROM_UNIXTIME(createtime,'%Y-%m-%d %H:%i:%s') as createTime, ispush from test_log_${startYearMonth} WHERE createtime>=${startTimeStamp} AND createtime<=${endTimeStamp};" > ${dstFileUtf8Txt}
if [[ $? -ne 0 ]]; then
    echo "== mysql query failed =="
    exit 3
fi

# 注意是3个字段，但是createTime值自带了1个空格
awk -F " " '{if(NR==1){print $1",",$2",", $3}else{print $1",",$2" "$3",", $4}}' ${dstFileUtf8Txt} > ${dstFileUtf8Csv}
if [[ $? -ne 0 ]]; then
    echo "== handle file failed =="
    exit 4
fi

# utf-8转换成gbk格式
iconv -f utf8 -t gb2312 -o ${dstFile} ${dstFileUtf8Csv}
if [[ $? -ne 0 ]]; then
    echo "== iconv failed =="
else
    echo "== iconv success. =="
fi
