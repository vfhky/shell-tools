#!/bin/bash
# FileName:      handle_makefile.sh
# Description:   Simple usage of sed command to modify many Makefiles in batch processing.
# Simple Usage:  ./handle_makefile.sh
# (c) 2016 vfhky https://typecodes.com/linux/handlemakefilebysed.html
# https://github.com/vfhky/shell-tools/blob/master/filehandle/handle_makefile.sh


# Dir to be handled.
SRC_DIR="/home/vfhky/shell"
# The makefile you want to modify.
SEARCH_NAME="Makefile"

####
# @param:	$1 	Name of the file
####
function handle()
{
	echo -e 'Handling file=['$1']'
	sed -i \
		-e 's/-std=c99 -D_GNU_SOURCE /-D_GNU_SOURCE/'	\
		-e 's/CC    	+= $(STD_OPT)/CC    	+= -std=c99 $(STD_OPT)/'	\
		-e '/help:/ a\
	@echo CC=[$(CC)]\
	@echo CXX=[$(CXX)]\
	@echo CFLAGS=[$(CFLAGS)]\
	@echo CXXFLAGS=[$(CXXFLAGS)]'	\
		-e '/	@echo STD_OPT=\[$(STD_OPT)\]/d'	\
		-e '/	@echo CFLAGS=\[$(CFLAGS)\]/d'	\
		 $1
	#echo "" | awk '{fflush()}'
}

# Get the target files you want to modify.
ALL_MAKEFILE=$(find ${SRC_DIR} -type f -name ${SEARCH_NAME})


# Traverse the target files.
for FILE in ${ALL_MAKEFILE}
do
	handle ${FILE}
	if [ $? -gt 0 ]; then
		echo 'failed.'
		#echo "" | awk '{fflush()}'
	fi	
done
