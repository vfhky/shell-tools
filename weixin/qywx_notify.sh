#!/bin/bash
# shell脚本通过企业微信用户，给企业微信下面的用户发通知。
# 使用 https://github.com/danni-cool/wechatbot-webhook 创建容器后即可以作为webhook使用.
# (c) 2024.05 vfhky https://typecodes.com/linux/qywx_notify.html
# https://github.com/vfhky/shell-tools/blob/master/weixin/qywx_notify.sh

# 企业微信应用密钥相关配置
QYWX_SECRET='QE_'
QYWX_CROP_ID='w'
QYWX_AGENT_ID='1000'

# 获取token
MY_QYWX_TOKEN_URI="https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=${QYWX_CROP_ID}&corpsecret=${QYWX_SECRET}"
qywx_token=$(curl -s -G $MY_QYWX_TOKEN_URI | awk -F \" '{print $10}')
# push地址
MY_QYWX_PUSH_URI="https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=$qywx_token"

echo "qywx_token=[${qywx_token}]"

if [ -z "$qywx_token" ]; then
    echo "获取token失败，请检查企业微信的密钥等配置"
    exit 0
fi

# 发送的内容
message_content='test msg'
# 发送的对象。也可以是全体成员：@all
notify_user='vfhky@typecodes.com'

# json内容
body="{
\"touser\": \"${notify_user}\",
\"msgtype\": \"text\",
\"agentid\": ${QYWX_AGENT_ID},
\"text\": {
    \"content\": \"${message_content}\"
},
\"safe\": 0,
\"enable_id_trans\": 0,
\"enable_duplicate_check\": 0
}"

# 发送消息
curl --data-ascii "$body" ${MY_QYWX_PUSH_URI}

printf "\n=== 结束 ===\n"
