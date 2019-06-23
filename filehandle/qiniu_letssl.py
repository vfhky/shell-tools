#!/usr/bin/python
# -*- coding: UTF-8 -*-

# FileName:      qiniu_letssl.py
# (c) 2019.6.23 vfhky https://typecodes.com/python/qiniuletssl1.html
# https://github.com/vfhky/shell-tools/blob/master/filehandle/qiniu_letssl.py
# 脚本功能：上传从Let's Encrypt申请的 cdn.typecodes.com 的SSL证书到七牛云存储并启用。
# 使用方法: python qiniu_letssl.py
#
# 必须安装的核心包：             pip install qiniu

import qiniu
from qiniu import DomainManager
import os
import time

# 七牛云API相关的AccessKey和SecretKey.
# access_key = os.getenv('ACCESS_KEY', '')
access_key = "ac_key"
secret_key = "se_key"
# 操作的域名
domain_name = "cdn.typecodes.com"

auth = qiniu.Auth(access_key=access_key, secret_key=secret_key)
domain_manager = DomainManager(auth)

# Let's Encrypt申请的证书公钥和私钥文件所在的目录.
privatekey = "/etc/letsencrypt/live/{}/privkey.pem".format(domain_name)
ca = "/etc/letsencrypt/live/{}/fullchain.pem".format(domain_name)

with open(privatekey, 'r') as f:
    privatekey_str = f.read()

with open(ca, 'r') as f:
    ca_str = f.read()

ret, info = domain_manager.create_sslcert("{}/{}".format(domain_name, time.strftime("%Y%m%d_%M%S", time.localtime())),
                                        domain_name, privatekey_str, ca_str)
print(ret['certID'])

if domain_name.startswith("*"):
    domain_name = domain_name[1:]
ret, info = domain_manager.put_httpsconf(domain_name, ret['certID'], False)
print(info)
