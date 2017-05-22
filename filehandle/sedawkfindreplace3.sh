#!/bin/bash
# FileName:      sedawkfindreplace3.sh
# Description:   Basic usage of sed and awk command such as find and replace words in the regular expression.
# Simple Usage:  ./sedawkfindreplace1.sh
# (c) 2017.5.22 vfhky https://typecodes.com/linux/sedawkfindreplace3.html
# https://github.com/vfhky/shell-tools/blob/master/filehandle/sedawkfindreplace3.sh


# Dir to be handled for windows.
# SRC_DIR="/e/typecodes.com/vfhky/src"
# Dir to be handled for Linux.
SRC_DIR="/home/vfhky/src"
# The makefile you want to modify.
SEARCH_NAME="Makefile*"
# The maximum depth of the dirs where files such as Makefile you're dealing with lies in.
MAXDEPTH=10

# Get the target files you want to modify.
ALL_MAKEFILE=$(find ${SRC_DIR} -maxdepth ${MAXDEPTH} -type f -name "${SEARCH_NAME}")


# Traverse the target files.
for FILE in ${ALL_MAKEFILE}
do
	echo -e 'Handling file=['${FILE}']'
	#### Ways recommended: find "-$(RM) $(ULT_BIN)" by awk command.
	#awk '/\$\(CURDIR\)\/\%\.o\: \%\.cpp/{printf( "[%s:%d]: %s\n", FILENAME, NR, $0) }' ${FILE}
	#awk '/-lprint$/{printf( "[%s:%d]: %s\n", FILENAME, NR, $0) }' ${FILE}
	
	#### replace "-$(RM) $(ULT_BIN)" with "-$(RM) $(ULT_BIN) $(ULT_LIBS)" using awk command.
	# awk '{sub(/-\$\(RM\) \$\(ULT_BIN\)/,"-\$\(RM\) \$\(ULT_BIN\) \$\(ULT_LIBS\)"); print $0}' ${FILE} > ${FILE}.tmp; cp ${FILE}.tmp ${FILE}; rm -rf ${FILE}.tmp
	
	
	#### find "-$(RM) $(ULT_BIN)" by sed command.
	#sed -n "/\$(CURDIR)\/\%.o: \%.c$/p" ${FILE}
	
	#### Ways recommended: Step1. replace "-$(RM) $(ULT_BIN)" with "-$(RM) $(ULT_BIN) $(ULT_LIBS)" using sed command.
	
	## 替换
	sed -i 's#\$(CURDIR)\/\%.o: \%.cpp$#\$(CURDIR)\/\%.o: \$(CURDIR)\/\%.cpp#g' ${FILE}
	
	## 替换
	sed -i 's#\$(CURDIR)\/\%.o: \%.c$#\$(CURDIR)\/\%.o: \$(CURDIR)\/\%.c#g' ${FILE}
	
	## 替换
	sed -i 's#$(bin).o#\$(CURDIR)\/$(bin).o#g' ${FILE}
	
	## 追加
	sed -i '/ -o \$\$\@$/ a\
	@echo \"========================Success========================\"' ${FILE}
	
	## 追加
	sed -i '/\$\$\@ \$\$\^)$/ a\
	@echo \"========================Success========================\"' ${FILE}
done

exit 0
