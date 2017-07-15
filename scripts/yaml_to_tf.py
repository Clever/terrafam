from __future__ import print_function
import json
import yaml
import sys
import os
import argparse

region = os.environ["AWS_REGION"]
account = os.environ["AWS_ACCOUNT_ID"]

def dump_tf_to_file(filename, tf):
    with open(filename, 'w') as outfile:
        json.dump(tf, outfile, indent=4, separators=(',', ': '))

def iam_role(tf, service):
    module_name = "{0}_role".format(service.replace("-", "_"))
    tf["module"][module_name] = { "source": "modules/role" }
    tf["module"][module_name]["role_name"] = service
    tf["module"][module_name]["assume_role_policy"] = '${file("policies/service-assume-role.policy")}'
    tf["module"][module_name]["description"] = service

def dynamodb(tf, service, requirements):
    for access, tables in requirements.items():
        for table in tables:
            module_name = "{0}_dynamodb_{1}_policy".format(service.replace("-", "_"), table.replace("-", "_"))
            tf["module"][module_name] = { "source": "modules/policy/dynamodb/role" }
            tf["module"][module_name]["table_name"] = table
            module_role_name = "${{module.{0}_role.name}}".format(service.replace("-", "_"))
            tf["module"][module_name]["role_name"] = module_role_name
            tf["module"][module_name]["access_level"] = access
            tf["module"][module_name]["region"] = region
            tf["module"][module_name]["account"] = account

def s3(tf, service, requirements):
    for access, buckets in requirements.items():
        for bucket in buckets:
            module_name = "{0}_s3_{1}_policy".format(service.replace("-", "_"), bucket.replace("-", "_"))
            tf["module"][module_name] = { "source": "modules/policy/s3/role" }
            module_role_name = "${{module.{0}_role.name}}".format(service.replace("-", "_"))
            tf["module"][module_name]["role_name"] = module_role_name
            tf["module"][module_name]["bucket_name"] = bucket
            tf["module"][module_name]["access_level"] = access

def sns(tf, service, requirements):
    for access, topics in requirements.items():
        for topic in topics:
            module_name = "{0}_sns_{1}_policy".format(service.replace("-", "_"), topic.replace("-", "_"))
            tf["module"][module_name] = { "source": "modules/policy/sns/role" }
            module_role_name = "${{module.{0}_role.name}}".format(service.replace("-", "_"))
            tf["module"][module_name]["role_name"] = module_role_name
            tf["module"][module_name]["topic_name"] = topic
            tf["module"][module_name]["access_level"] = access
            tf["module"][module_name]["region"] = region
            tf["module"][module_name]["account"] = account

def custom(tf, service):
    resource_name = "{0}_custom_policy".format(service.replace("-", "_"))
    if not "aws_iam_role_policy" in tf["resource"]:
        tf["resource"]["aws_iam_role_policy"] = {}
    tf["resource"]["aws_iam_role_policy"][resource_name] = {}
    tf["resource"]["aws_iam_role_policy"][resource_name]["name"] = resource_name
    tf["resource"]["aws_iam_role_policy"][resource_name]["role"] = service
    policy = '${{file("policies/{0}.policy")}}'.format(service)
    tf["resource"]["aws_iam_role_policy"][resource_name]["policy"] = policy

def generate_tf(data, filename):
    tf = {"module": {}, "resource": {}}
    for service, values in sorted(data.items()):
        iam_role(tf, service)
        for resource in values:
            if resource == "s3":
                requirements = values[resource]
                s3(tf, service, requirements)
            if resource == "dynamodb":
                tables = values[resource]
                dynamodb(tf, service, tables)
            if resource == "sns":
                tables = values[resource]
                sns(tf, service, tables)
            if resource == "custom":
                custom(tf, service)
    dump_tf_to_file(filename, tf)

stream = open("roles.yml", "r")
for data in yaml.load_all(stream):
    generate_tf(data, "roles.tf.json")
