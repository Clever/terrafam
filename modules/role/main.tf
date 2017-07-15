#######################
# IAM Role
#######################

variable "role_name" {
  type = "string"
}

variable "assume_role_policy" {
  type = "string"
}

variable "description" {
  type = "string"
}

resource "aws_iam_role" "service" {
  name = "${var.role_name}"
  assume_role_policy = "${data.aws_iam_policy_document.assume-role-policy.json}"
}

data "aws_iam_policy_document" "assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

output "role_name" {
  value = "${var.role_name}"
}

output "name" {
  value = "${aws_iam_role.service.name}"
}

output "arn" {
  value = "${aws_iam_role.service.arn}"
}
