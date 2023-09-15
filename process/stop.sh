#!/bin/bash
# FileName:      stop.sh
# Description:   通过输入进程名，然后检查进程是否存在，存在则发送SIGKILL信号给进程使其退出。
#                 如果进程捕捉了该信号，则可以把下面代码中的KILL 改成 kill -9 强杀进程，但是不建议!
# Simple Usage:  ./stop.sh processName
# (c) 2023.09.15 vfhky https://typecodes.com
# https://github.com/vfhky/shell-tools/blob/master/process/stop.sh



if [ $# -ne 1 ]; then
    echo "usage : ./stop.sh appName"
    exit 1
fi


appName="./"$1
echo "==${appName}==="

ps ux
#pids=$(ps ux |grep "${appName}" | grep -Ev "grep|tail|less|update| Dl " | awk -F ' ' '{print $2}')
pids=$(pgrep -f "${appName}")
echo "=== stop begin pids=[${pids}] ==="

if [ -n "$pids" ]; then
    for pid in ${pids}
    do
        echo "=== stop ok pid=[${pid}] ==="
        kill "${pid}"
    done
fi
echo "=== stop end pids=[${pids}] ==="
