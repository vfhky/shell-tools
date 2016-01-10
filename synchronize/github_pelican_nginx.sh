#!/bin/bash
# FileName:		 github_pelican_nginx.sh
# Description:	 Synchronize markdown articles with github, convert to html files using Pelican, deliver it to nginx environment.
# Simple Usage:	 ./github_pelican_nginx.sh "commit_comments"
# Crontab Usage: 00 01 * * * /mydata/backups/bak_list/github_pelican_nginx.sh >/dev/null 2>&1
# (c) 2016 vfhky https://typecodes.com/linux/githubpelicanpublishshell.html
# https://github.com/vfhky/shell-tools/blob/master/synchronize/github_pelican_nginx.sh


# Basic command.
FINDCMD="find"
MVCMD="\mv -f"
CPCMD="\cp -rf"
RMCMD="\rm -rf"
TARXCMD="tar -zxf"
TARZIPCMD="tar --warning=no-file-changed -zcf"

# Pelican compile markdown files to html.
PELICAN_COMPILE_DIR=/mydata/GitBang/pelican
# Private bang in github for store your markdown files.
GITHUB_PELICAN_DIR=/mydata/GitBang/GitHub/BlogBak
# Backup dir for your website's version management.
PELICAN_TAR_DIR=/usr/share/nginx/html/pelican_content_bak
# Dir of your website in nginx server.
PELICAN_BLOG_DIR=/usr/share/nginx/html/pelican
# Dir for this shell script to generate logs automatically.
BLOG_PUBLISH_LOG_DIR=/mydata/backups/logs/blogpublish
# Your personal homepage in github.
GITHUB_PERSONAL_PAGE=/mydata/GitBang/GitHub/vfhky.github.io
# Articles in 15 minutes are legal.
TIME_GAP=15

# Get the newest file name.
#Newest_File="ls -lrt| tail -n 1 | awk '{print $9}'"

# Name of this shell script.
PRGNAME="github_pelican_nginx"

# Current date format: e.g 20150505_2015.
Current_Date=$(date +%Y%m%d_%H%M)

# Check if current user is root.
[ "$(id -u)" != "0" ] && echo "Error: You must be root to run this script." && exit 1

# Check parameter.
if [ $# -gt 1 ]; then
	echo "Usage:	./github_pelican_nginx.sh \"commit_comments\"" && exit 1
fi

# Run command functions.
function ERROR() {
	echo >/dev/null && echo "[$(date +%Y%m%d_%H%M)][error] $*" >> ${BLOG_PUBLISH_LOG_DIR}/${Current_Date}.log
	exit 1
}

function NOTICE() {
	echo >/dev/null && echo "[$(date +%Y%m%d_%H%M)][notice] $*" >> ${BLOG_PUBLISH_LOG_DIR}/${Current_Date}.log
}

function RUNCMD() {
	echo "[$(date +%Y%m%d_%H%M)][notice] $*" >> ${BLOG_PUBLISH_LOG_DIR}/${Current_Date}.log
	eval $@
}

# Git pull command function.
function Git_Pull(){
  	RUNCMD "git pull origin master >/dev/null"
}

# Git commit command function.
function Git_Commit(){
  if [ $# -ne 1 ]; then
  	ERROR "Usage: Git_Commit commit_comments!"
  	exit 1;
  else
  	RUNCMD git pull && git add --all && git commit -m "$1" && git push origin master
  fi
}

# Get the path of markdown articles in TIME_GAP minutes.
function Get_Files_Path(){
  	RUNCMD "${FINDCMD} . -mmin -${TIME_GAP} -type f -name \"*.md\" -print0"
}

# Lock down permissions.You should be careful when it comes to your website for the permission of files, but it's safe using 022.
# umask 022

# Create the log dir.
if [ ! -d $BLOG_PUBLISH_LOG_DIR ]; then
	mkdir -p $BLOG_PUBLISH_LOG_DIR
fi


# Main process begin.
NOTICE "[1]Start pull from GitHub."
RC=0
RUNCMD "cd ${GITHUB_PELICAN_DIR}/md_article && Git_Pull"

RC=$?
if [ $RC -gt 0 ]; then
	ERROR "Git pull failed!"
fi


NOTICE "[2]Start copy the pulled articles to the compile dir of PELICAN."
New_Article_Files=$(Get_Files_Path ${GITHUB_PELICAN_DIR}/md_article)
# You should not delete the double quotation marks in case of existing a blank in the file path.
for New_Article_File in "${New_Article_Files}"
do
	if [ -z "${New_Article_File}" ]; then
		echo "No articles, nothing to do."
		ERROR "No articles, nothing to do."
	fi
	FILE_PATH=$(dirname ${PELICAN_COMPILE_DIR}/content/articles/"${New_Article_Files:2}")
	RUNCMD "mkdir -p ${FILE_PATH} && ${CPCMD} \"${New_Article_File}\" ${FILE_PATH}"
done

RC=$?
if [ $RC -gt 0 ]; then
	ERROR "Copy the pulled articles failed!"
fi


NOTICE "[3]Start compile in pelican."
RUNCMD "cd ${PELICAN_COMPILE_DIR} && make publish > /dev/null"

RC=$?
if [ $RC -gt 0 ]; then
	ERROR "Compile in pelican failed!"
fi


NOTICE "[4]Start generate a tar packgage and move it to the backup dir."
# The command of tar cause the problem that file changed as we read with the value 1, so we should ignore it using OR logic.
RUNCMD "cd ${PELICAN_COMPILE_DIR}/output && ${TARZIPCMD} ${Current_Date}.tar.gz . || ${MVCMD} ${Current_Date}.tar.gz ${PELICAN_TAR_DIR}"

RC=$?
if [ $RC -gt 0 ]; then
	ERROR "Generate a tar packgage failed!"
fi


NOTICE "[5]Start unpack the target files."
RUNCMD "${CPCMD} ${PELICAN_TAR_DIR}/${Current_Date}.tar.gz ${PELICAN_BLOG_DIR} && cd ${PELICAN_BLOG_DIR} && ${TARXCMD} ${Current_Date}.tar.gz && ${RMCMD} ${Current_Date}.tar.gz"

RC=$?
if [ $RC -gt 0 ]; then
	ERROR "Unpack the target files failed!"
fi

# if [ $# -eq 1 ]; then
if [ -n "$1" ]; then
	echo "You're going to synchronize your weibsite to the homepage on github.com."
	NOTICE "[6]Start copy the packgage to the local homepage bang cloned from remote in GitHub."
	RUNCMD "${CPCMD} ${PELICAN_TAR_DIR}/${Current_Date}.tar.gz ${GITHUB_PERSONAL_PAGE} && cd ${GITHUB_PERSONAL_PAGE} && ${TARXCMD} ${Current_Date}.tar.gz && ${RMCMD} ${Current_Date}.tar.gz"
	
	RC=$?
	if [ $RC -gt 0 ]; then
		ERROR "Copy the packgage to the local homepage bang failed!"
	fi
	
	NOTICE "[7]Start synchronize website to my homepage on GitHub."
	# read -p "Please input your comments on this commitment: " COMMIT_COMMENTS
	# while [[ -z "${COMMIT_COMMENTS}" ]]
	# do
	# 	read -p "Comments can not be empty.Please input again: " COMMIT_COMMENTS
	# done
	# RUNCMD "Git_Commit \"${COMMIT_COMMENTS}\""
	RUNCMD "Git_Commit \"$1\""
	
	RC=$?
	if [ $RC -gt 0 ]; then
		ERROR "Synchronize website to GitHub failed!"
	fi
else
	echo "Not synchronize your weibsite to the homepage on github.com."
	NOTICE "[6]Not synchronize your weibsite to the homepage on github.com."
fi


NOTICE "------END------"
exit 0
