#!/bin/bash
# FileName:      python3caseyumbug2.sh
# Description:   修复CentOS7升级Python到3.6版本后yum不能使用的问题（续）
# Simple Usage:  sh python3caseyumbug2.sh
# (c) 2018.01.28 vfhky https://typecodes.com/linux/python3caseyumbug2.html
# https://github.com/vfhky/shell-tools/blob/master/filehandle/python3caseyumbug2.sh


echo "begin handle /usr/bin/yum*."
ALL_YUM_FILES=$(find /usr/bin/ -type f -name "yum*")
for SINGLE_FILE in ${ALL_YUM_FILES}
do
	sed -i 's/#!\/usr\/bin\/python$/#!\/usr\/bin\/python2/' ${SINGLE_FILE}
done


echo "begin handle /usr/libexec/urlgrabber-ext-down."
sed -i 's/\/usr\/bin\/python$/\/usr\/bin\/python2/' /usr/libexec/urlgrabber-ext-down

echo "done."

exit 0
