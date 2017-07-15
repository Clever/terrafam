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

def iam_user(tf, user):
    if not "aws_iam_user" in tf["resource"]:
        tf["resource"]["aws_iam_user"] = {}
    tf["resource"]["aws_iam_user"][user] = {"name": user}

def iam_role(tf, role):
    if not "aws_iam_role" in tf["resource"]:
        tf["resource"]["aws_iam_role"] = {}
        tf["data"] = {}
        tf["data"]["aws_iam_policy_document"] = {}
    tf["resource"]["aws_iam_role"][role] = {"name": role}
    tf["data"]["aws_iam_policy_document"]["{}_assume_role_policy".format(role)] = {
        "policy_id": "",
        "statement": {
            "actions": ["sts:AssumeRole"],
            "principals": {
                "type": "Service",
                "identifiers": ["ec2.amazonaws.com"]
            }
        }
    }
    assume_role_location = '${data.aws_iam_policy_document.' + role + '_assume_role_policy.json}'
    tf["resource"]["aws_iam_role"][role]["assume_role_policy"] = assume_role_location

def iam_group(tf, group):
    if not "aws_iam_group" in tf["resource"]:
        tf["resource"]["aws_iam_group"] = {}
    tf["resource"]["aws_iam_group"][group] = {"name": group}

def dynamodb(tf, principal, principal_type, requirements):
    for access, tables in requirements.items():
        for table in tables:
            module_name = "{0}_dynamodb_{1}_policy".format(principal, table)
            tf["module"][module_name] = { "source": "modules/dynamodb/{}".format(principal_type) }
            tf["module"][module_name]["table_name"] = table
            principal_name =  "${{aws_iam_{}.{}.name}}".format(principal_type, principal)
            tf["module"][module_name]["name"] = principal_name
            tf["module"][module_name]["access_level"] = access
            tf["module"][module_name]["region"] = region
            tf["module"][module_name]["account"] = account

def s3(tf, principal, principal_type, requirements):
    for access, buckets in requirements.items():
        for bucket in buckets:
            module_name = "{0}_s3_{1}_policy".format(principal, bucket)
            tf["module"][module_name] = { "source": "modules/s3/{}".format(principal_type) }
            principal_name =  "${{aws_iam_{}.{}.name}}".format(principal_type, principal)
            tf["module"][module_name]["name"] = principal_name
            tf["module"][module_name]["bucket_name"] = bucket
            tf["module"][module_name]["access_level"] = access

def sns(tf, principal, principal_type, requirements):
    for access, topics in requirements.items():
        for topic in topics:
            module_name = "{0}_sns_{1}_policy".format(principal, topic)
            tf["module"][module_name] = { "source": "modules/sns/{}".format(principal_type) }
            principal_name =  "${{aws_iam_{}.{}.name}}".format(principal_type, principal)
            tf["module"][module_name]["name"] = principal_name
            tf["module"][module_name]["topic_name"] = topic
            tf["module"][module_name]["access_level"] = access
            tf["module"][module_name]["region"] = region
            tf["module"][module_name]["account"] = account

def custom(tf, principal, principal_type):
    resource_name = "{0}_custom_policy".format(principal)
    if not "aws_iam_role_policy" in tf["resource"]:
        tf["resource"]["aws_iam_role_policy"] = {}
    tf["resource"]["aws_iam_role_policy"][resource_name] = {}
    tf["resource"]["aws_iam_role_policy"][resource_name]["name"] = resource_name
    tf["resource"]["aws_iam_role_policy"][resource_name]["role"] = principal
    policy = '${{file("policies/{0}.policy")}}'.format(principal)
    tf["resource"]["aws_iam_role_policy"][resource_name]["policy"] = policy

def generate_tf(data, principal_type):
    tf = {"module": {}, "resource": {}}
    for principal, values in sorted(data.items()):
        if principal_type == "user":
            iam_user(tf, principal)
        if principal_type == "role":
            iam_role(tf, principal)
        if principal_type == "group":
            iam_group(tf, principal)
        for resource in values:
            if resource == "s3":
                requirements = values[resource]
                s3(tf, principal, principal_type, requirements)
            if resource == "dynamodb":
                tables = values[resource]
                dynamodb(tf, principal, principal_type, tables)
            if resource == "sns":
                tables = values[resource]
                sns(tf, principal, principal_type, tables)
            if resource == "custom":
                custom(tf, principal, principal_type)
    dump_tf_to_file("{}s.tf.json".format(principal_type), tf)

for p in ["user", "role", "group"]:
    stream = open(p + "s.yml", "r")
    for data in yaml.load_all(stream):
        generate_tf(data, p)
