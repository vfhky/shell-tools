#!/bin/bash
# shell脚本给微信用户发通知。使用【文件传输助手】进行测试。
# 使用 https://github.com/danni-cool/wechatbot-webhook 创建容器后即可以作为webhook使用.
# (c) 2024.05 vfhky https://typecodes.com/linux/wx_notify.html
# https://github.com/vfhky/shell-tools/blob/master/weixin/wx_notify.sh

MY_WX_PUSH_TOKEN='上面wechatbot-webhook容器生成的token'
MY_WX_PUSH_URI='https://typecodes.com/webhook/msg/v2?token='"${MY_WX_PUSH_TOKEN}"
MY_WX_PUSH_USER='文件传输助手'
test_uri='http://typecodes.com'
# 推送参数
title='1111'; status='2222'; name='3333'; contents='4444';
# 拼接text字段，格式为markdown
message_content="# [${title}](${test_uri})\n---\n"
# 构建JSON消息体数组
message_data='[
  {
    "type": "text",
    "content": "'"${message_content}"'"
  },
  {
    "type": "fileUrl",
    "content": "'"${test_uri}"'"
  }
]'
# 构建最终的JSON数据
json_data='{
  "to": "'"${MY_WX_PUSH_USER}"'",
  "data": '"${message_data}"'
}'
# 发送Curl请求
curl --location "${MY_WX_PUSH_URI}" \
    --header 'Content-Type: application/json' \
    --data "${json_data}"

