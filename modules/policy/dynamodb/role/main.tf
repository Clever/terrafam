variable "name" {
  type = "string"
}

variable "table_name" {
  type = "string"
}

variable "region" {
  type = "string"
}

variable "account" {
  type = "string"
}

variable "access_level" {
  type = "string"
  description = "Can be read, write, or read-and-write"
}

data "aws_iam_policy_document" "read" {
  statement {
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:Describe*",
      "dynamodb:Get*",
      "dynamodb:Query",
      "dynamodb:Scan"
    ]
    resources = [
      "arn:aws:dynamodb:${var.region}:${var.account}:table/${var.table_name}",
    ]
  }
}

data "aws_iam_policy_document" "write" {
  statement {
    actions = [
      "dynamodb:BatchWriteItem",
      "dynamodb:DeleteItem",
      "dynamodb:PutItem",
      "dynamodb:Update*",
      "dynamodb:TagResource",
      "dynamodb:UntagResource"
    ],
    resources = [
      "arn:aws:dynamodb:${var.region}:${var.account}:table/${var.table_name}",
    ]
  }
}

resource "aws_iam_role_policy" "dynamodb_read_policy" {
    name = "dynamodb_read_${replace(var.table_name, "-", "_")}_table"
    role = "${var.name}"
    count = "${replace(var.access_level, "-and-write", "") == "read" ? 1 : 0}"
    policy = "${data.aws_iam_policy_document.read.json}"
}

resource "aws_iam_role_policy" "dynamodb_write_policy" {
    name = "dynamodb_write_${replace(var.table_name, "-", "_")}_table"
    role = "${var.name}"
    count = "${replace(var.access_level, "read-and-", "") == "write" ? 1 : 0}"
    policy = "${data.aws_iam_policy_document.write.json}"
}
