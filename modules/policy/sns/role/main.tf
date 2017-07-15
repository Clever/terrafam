variable "role_name" {
  type = "string"
}

variable "topic_name" {
  type = "string"
}

variable "access_level" {
  type = "string"
  description = "Can be read, write, or read-and-write"
}

variable "region" {
  type = "string"
}

variable "account" {
  type = "string"
}

data "aws_iam_policy_document" "read" {
  statement {
    actions = [
      "sns:Subscribe"
    ]
    resources = [
      "arn:aws:sns:${var.region}:${var.account}:${var.topic_name}"
    ]
  }
}

data "aws_iam_policy_document" "write" {
  statement {
    actions = [
      "sns:Publish"
    ]
    resources = [
      "arn:aws:sns:${var.region}:${var.account}:${var.topic_name}"
    ]
  }
}

resource "aws_iam_role_policy" "sns_read_policy" {
    name = "sns_read_${replace(var.topic_name, "-", "_")}_topic"
    role = "${var.role_name}"
    count = "${replace(var.access_level, "-and-write", "") == "read" ? 1 : 0}"
    policy = "${data.aws_iam_policy_document.read.json}"
}

resource "aws_iam_role_policy" "sns_write_policy" {
    name = "sns_write_${replace(var.topic_name, "-", "_")}_topic"
    role = "${var.role_name}"
    count = "${replace(var.access_level, "read-and", "") == "write" ? 1 : 0}"
    policy = "${data.aws_iam_policy_document.write.json}"
}
