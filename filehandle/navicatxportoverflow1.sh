#!/bin/bash
# FileName:      navicatxportoverflow1.sh
# Description:   使用shell脚本解决Navicat导出excel数据不全的问题
# Simple Usage:  sh navicatxportoverflow1.sh file_name.txt
# (c) 2018.02.07 vfhky https://typecodes.com/linux/navicatxportoverflow1.html
# https://github.com/vfhky/shell-tools/blob/master/filehandle/navicatxportoverflow1.sh


dst_file=$1
dst_ile_name=$(basename ${dst_file})
dst_ile_name_prefix=${dst_ile_name%.*}


cp ${dst_file} ${dst_ile_name_prefix}.tmp
sed -i 's/\t/,/g' ${dst_ile_name_prefix}.tmp
awk -F',' '{print $1",`"$2","$3}' ${dst_ile_name_prefix}.tmp > ${dst_ile_name_prefix}.tmp1
iconv -f "utf-8" -t "gbk" ${dst_ile_name_prefix}.tmp1 > ${dst_ile_name_prefix}.csv
rm -rf ${dst_ile_name_prefix}.tmp ${dst_ile_name_prefix}.tmp1


exit 0
