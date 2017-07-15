# terraform-iam
`terraform-iam` makes it easy to create AWS IAM principals with limited permission to AWS resources. You define your users, roles, and groups, as well as their AWS access policies in terse yml configuration files. You can then generate and use terraform configuration to create the IAM resources.

## roles.yml

```
example-role:
    s3:
      read-and-write: ["some-bucket"]
      read: ["another-bucket"]

example-role:
    dynamodb:
      read: ["some-table"]
    custom: true
```

Run `python scripts/generate_tf.py` and you'll get a `roles.tf.json`. From there, you can `terraform plan` and `terraform apply`.
