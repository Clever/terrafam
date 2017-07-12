#######################
# IAM Role
#######################

variable "role_name" {
  type = "string"
}

variable "assume_role_policy" {
  type = "string"
}

variable "policy" {
  type = "string"
}

variable "description" {
  type = "string"
}

resource "aws_iam_role" "service" {
  name = "${var.role_name}"
  assume_role_policy = "${var.assume_role_policy}"
}

resource "aws_iam_policy" "service-policy" {
  name = "${var.role_name}-policy"
  description = "${var.description}"
  policy = "${var.policy}"
}

resource "aws_iam_role_policy_attachment" "service-policy-attach" {
  role = "${aws_iam_role.service.name}"
  policy_arn = "${aws_iam_policy.service-policy.arn}"
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

output "policy_arn" {
  value = "${aws_iam_policy.service-policy.arn}"
}
