#!/usr/bin/python
# -*- coding: UTF-8 -*-

# FileName:      aliyun_dns_modify.py
# (c) 2019.6.1 vfhky https://typecodes.com/python/aliyundnsanalysis1.html
# https://github.com/vfhky/shell-tools/blob/master/dns/aliyun_dns_modify.py
# 脚本功能：修改 cdn.typecodes.com 在阿里云DNS的解析（七牛和源主机之间的切换）。
# 使用方法: python aliyun_dns_modify.py cdn 1/2
#
# 必须安装的核心包：             pip install aliyun-python-sdk-core
# 根据功能选装dns相关的包：       pip install aliyun-python-sdk-alidns


import sys
import json
from aliyunsdkcore.client import AcsClient
from aliyunsdkcore.acs_exception.exceptions import ClientException
from aliyunsdkcore.acs_exception.exceptions import ServerException
from aliyunsdkalidns.request.v20150109.DescribeDomainRecordsRequest import DescribeDomainRecordsRequest
from aliyunsdkalidns.request.v20150109.UpdateDomainRecordRequest import UpdateDomainRecordRequest


# constant statics.
aliyun_accesskey = "key"
aliyun_accesskeysecret = "secret"
domain_pre = "cdn"
# must be the root domain other than the second or third level domain.
domain = "typecodes.com"
# the dns record type which is defined 1 meaning qiniu defaultly.
record_type = 1
# qiniu.
qiniu_cname = ("CNAME", "cdn.typecodes.com.qiniudns.com")
# host ip.
original_host = ("A", "111.231.246.29")


# create aliyun api object.
client = AcsClient(
  aliyun_accesskey,
  aliyun_accesskeysecret
);



if __name__ == '__main__':
    if len(sys.argv) == 3:
        domain_pre = sys.argv[1]
        record_type = int(sys.argv[2])
    else:
        print("==== usage: python %s %s %d ====" % (sys.argv[0], domain_pre, record_type) )
        sys.exit(1)
        
    # first step: call aliyun api to get dns record lists.
    try:
        # domain act.
        request = DescribeDomainRecordsRequest()
        request.set_accept_format('json')
        request.set_DomainName( domain )
        response = client.do_action_with_exception(request)
    except ServerException as srv_ex:
    # if response.has_key('Code') or response.has_key('Message'):
        print("Error: Code=[%s] Message=[%s], exit." % (srv_ex.error_code, srv_ex.message) )
        sys.exit(1)
    except:
        print( "unexcepted error, exit." )
        sys.exit(1)

    # parse response: 
    data = json.loads(response)
    record = data["DomainRecords"]["Record"];

    # recrucive all dns record and find the RecordId of target pre-domain.
    for single_record in record:
        if ( single_record["RR"] == domain_pre ):
            print( "==== get domain=[%s] RR=[%s] RecordId=[%s] Type=[%s] Value=[%s]." % (domain, single_record["RR"], single_record["RecordId"], single_record["Type"], single_record["Value"] ) )
            # second step: call aliyun api to update the target record.
            request = UpdateDomainRecordRequest()
            request.set_accept_format('json')
            request.set_RR( domain_pre )
            request.set_RecordId( single_record["RecordId"] )
            
            if record_type == 1:
                request.set_Type( qiniu_cname[0] )
                request.set_Value( qiniu_cname[1] )
            else:
                request.set_Type( original_host[0] )
                request.set_Value( original_host[1] )
        
            try:
                response = client.do_action_with_exception(request)
            except ServerException as srv_ex:
            # if response.has_key('Code') or response.has_key('Message'):
                print("Error: Code=[%s] Message=[%s], exit." % (srv_ex.error_code, srv_ex.message) )
                sys.exit(1)
            except:
                print( "unexcepted error, exit." )
                sys.exit(1)
            
            print("==== success.")
        else:
            continue
 
