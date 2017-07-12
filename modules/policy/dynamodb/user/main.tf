variable "user_name" {
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

resource "aws_iam_user_policy" "dynamodb_policy" {
    name = "${var.user_name}_${var.access_level}_${var.table_name}_table_policy"
    user = "${var.user_name}"
    policy = "${data.template_file.dynamodb_policy_template.rendered}"
}
