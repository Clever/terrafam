# terraform-iam
`terraform-iam` makes it easy to create AWS IAM principals (users, roles, and groups) with limited permission to AWS resources. You define your users, roles, and groups, as well as their AWS access policies in terse YML configuration files, with sensible defaults.

You can then generate and use terraform configuration to create the IAM resources.

## users.yml

```
example-user:
    managed: ["AdministratorAccess"]
```

## roles.yml

```
example-role:
    s3:
      read-and-write: ["some-bucket"]
      read: ["another-bucket"]
```

## groups.yml

```
example-group:
    dynamodb:
      read: ["some-table"]
    custom: true
```

Run `python scripts/generate_tf.py` and you'll get `{users,roles,groups}.tf.json`.

From there, you can `terraform get`, `terraform plan` and `terraform apply`.
