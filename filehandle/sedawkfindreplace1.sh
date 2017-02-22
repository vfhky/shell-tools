#!/bin/bash
# FileName:      sedawkfindreplace1.sh
# Description:   Basic usage of sed and awk command such as find and replace words in the regular expression.
# Simple Usage:  ./sedawkfindreplace1.sh
# (c) 2017.2.22 vfhky https://typecodes.com/linux/sedawkfindreplace1.html
# https://github.com/vfhky/shell-tools/blob/master/filehandle/sedawkfindreplace1.sh


# Dir to be handled.
SRC_DIR="/home/vfhky/shell"
# The makefile you want to modify.
SEARCH_NAME="Makefile*"
# The maximum depth of the dirs where files such as Makefile you're dealing with lies in.
MAXDEPTH=10

# Get the target files you want to modify.
ALL_MAKEFILE=$(find ${SRC_DIR} -maxdepth ${MAXDEPTH} -type f -name "${SEARCH_NAME}")


# Traverse the target files.
for FILE in ${ALL_MAKEFILE}
do
	#### Ways recommended: find "CC    	:= g++" by awk command.
	awk '/CC    	:= g+\+/{printf( "[%s:%d]: %s\n", FILENAME, NR, $0) }' ${FILE}
	#### replace "g++" with "gcc" using awk command.
	# awk '{sub(/^CC    	:= g\+\+/,"CC    	:= gcc"); print $0}' ${FILE} > ${FILE}.tmp; cp ${FILE}.tmp ${FILE}; rm -rf ${FILE}.tmp
	
	
	#### find "CC    	:= g++" by sed command.
	# sed -n "/^CC    	:= g+\+/p" ${FILE}
	#### Ways recommended: replace "g++" with "gcc" using sed command.
	# sed -i "s#^CC    	:= g+\+#CC    	:= gcc#" ${FILE}
done

exit 0
