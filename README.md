# terrafam
`terrafam` makes it easy to create AWS IAM principals (users, roles, and groups) with limited permission to AWS resources. You define your users, roles, and groups, as well as their AWS access policies in terse YML configuration files, with sensible defaults.

You can then generate and use terraform configuration to create the IAM resources.

The resulting access policies can serve as the basic IAM structure for your org; you can decorate with additional IAM resources in terraform, or manually.

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

# Usage

* Start in your terraform directory, where `aws.region` is defined (see [main.tf](main.tf)).
* Define the `users.yml`, `roles.yml`, and `groups.yml` files.
* Make sure the `AWS_REGION` and `AWS_ACCOUNT_ID` environment variables are set.
* Download and run [scripts/yaml_to_tf.py](scripts/yaml_to_tf.py). `{users,roles,groups}.tf.json` files are generated.
* Define `custom` policies in the `policies` folder. A user with the name `example-user` would have a custom policy at `policies/user/example-user.policy`.
* Run `terraform get`, `terraform plan` and `terraform apply` to add the resources to your AWS account.
