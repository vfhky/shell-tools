#!shell
#!/bin/bash
# FileName:      batchinsertmysqlshell1.sh
# Description:   使用shell脚本批量插入数据到MySQL中
# Simple Usage:  sh batchinsertmysqlshell1.sh
# (c) 2020.04.15 vfhky https://typecodes.com/linux/batchinsertmysqlshell1.html
# https://github.com/vfhky/shell-tools/blob/master/mysql/batchinsertmysqlshell1.sh

# mysql db name.
db_name="gamedata"
# mysql table name.
table_name="test_user_skin"


beginTime=$(date "+%Y-%m-%d %H:%M:%S")
echo "==== ${beginTime} ===="

# logic begin.
index=0
# uid in [3000000,4999999].
for uid in {3000000..4999999}
do
	if [ `expr ${index} % 1000` -ne 0 ]; then
		insertValues+=",("${uid}",'2020-04-09 08:08:08')"
		index=$(( $index + 1 ))
	else
		index=1
		if [ -n "$insertValues" ]; then
			#echo "${insertValues}"
			# INSERT INTO `gamedata`.`test_user_skin`(`id`, `uid`, `due_time`, `create_time`, `update_time`, `extend`) VALUES (1156, 1007200, '2020-04-09 10:11:11', '2020-04-07 10:11:11', '2020-04-07 10:11:11', '');
			mysql -h11.36.122.55 -P6302 -utestuser -p123qwe -e "INSERT INTO ${db_name}.${table_name}(uid,due_time) values ${insertValues}"
		fi
		insertValues="("${uid}",'2020-04-09 08:08:08')"
	fi
done

if [ -z "${insertValues}" ]; then
	echo "empty."
else
	mysql -h11.36.122.55 -P6302 -utestuser -p123qwe -e "INSERT INTO ${db_name}.${table_name}(uid,due_time) values ${insertValues}"
fi

endTime=$(date "+%Y-%m-%d %H:%M:%S")
echo "==== ${endTime} ===="
