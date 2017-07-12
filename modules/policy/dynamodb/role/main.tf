variable "role_name" {
  type = "string"
}

variable "table_name" {
  type = "string"
}

variable "region" {
  type = "string"

  default = "us-west-1"
}

variable "access_level" {
  type = "string"
  description = "Can be read, write, or read-and-write"
}

data "template_file" "dynamodb_policy_template" {
    template = "${file("templates/dynamodb/${var.access_level}-table.tpl")}"
    vars {
        table_name = "${var.table_name}"
        region = "${var.region}"
    }
}

resource "aws_iam_role_policy" "dynamodb_policy" {
    name = "${replace(var.role_name, "-", "_")}_${replace(var.access_level, "-", "_")}_${replace(var.table_name, "-", "_")}_table_policy"
    role = "${var.role_name}"
    policy = "${data.template_file.dynamodb_policy_template.rendered}"
}
