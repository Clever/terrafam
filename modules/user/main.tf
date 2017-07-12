#######################
# IAM Users
#######################

variable "user_name" {
  type = "string"
}

resource "aws_iam_user" "service" {
    name = "${var.user_name}"
}

output "user_name" {
    value = "${var.user_name}"
}

output "name" {
    value = "${aws_iam_user.service.name}"
}

output "arn" {
    value = "${aws_iam_user.service.arn}"
}
