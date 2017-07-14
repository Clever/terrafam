# terraform-iam

The goal of this repository is to make it easy to create AWS IAM roles with limited permission to AWS resources. You can define your roles and users along with their AWS access in terse yml configuration files, and use terraform to apply the changes to your WAS infrastructure.

## Example roles.yml

```
some-service:
    s3:
      read-and-write: ["some-bucket"]
      read: ["another-bucket"]

another-service:
    dynamodb:
      read: ["some-table"]
    custom: true
```

Run `python generate_tf.py` and you'll get a `roles.tf.json`. From there, you can `terraform plan` and `terraform apply`.
