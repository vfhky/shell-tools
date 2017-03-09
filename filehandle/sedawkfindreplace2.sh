#!/bin/bash
# FileName:      sedawkfindreplace2.sh
# Description:   Basic usage of sed and awk command such as find and replace words in the regular expression.
# Simple Usage:  ./sedawkfindreplace1.sh
# (c) 2017.3.9 vfhky https://typecodes.com/linux/sedawkfindreplace2.html
# https://github.com/vfhky/shell-tools/blob/master/filehandle/sedawkfindreplace2.sh


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
	#### Ways recommended: find "-$(RM) $(ULT_BIN)" by awk command.
	#awk '/-\$\(RM\) \$\(ULT_BIN\)/{printf( "[%s:%d]: %s\n", FILENAME, NR, $0) }' ${FILE}
	
	#### replace "-$(RM) $(ULT_BIN)" with "-$(RM) $(ULT_BIN) $(ULT_LIBS)" using awk command.
	# awk '{sub(/-\$\(RM\) \$\(ULT_BIN\)/,"-\$\(RM\) \$\(ULT_BIN\) \$\(ULT_LIBS\)"); print $0}' ${FILE} > ${FILE}.tmp; cp ${FILE}.tmp ${FILE}; rm -rf ${FILE}.tmp
	
	
	#### find "-$(RM) $(ULT_BIN)" by sed command.
	#sed -n "/-\$(RM) \$(ULT_BIN)/p" ${FILE}
	
	#### Ways recommended: Step1. replace "-$(RM) $(ULT_BIN)" with "-$(RM) $(ULT_BIN) $(ULT_LIBS)" using sed command.
	#### Step2. delete the line contains the words "-$(RM) $(ULT_LIBS)".
	sed -i -e "s#-\$(RM) \$(ULT_BIN)#-\$(RM) \$(ULT_BIN) \$(ULT_LIBS)#" -e "/-\$(RM) \$(ULT_LIBS)/d" ${FILE}
done

exit 0
