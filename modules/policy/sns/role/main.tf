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

data "template_file" "sns_policy_template" {
    template = "${file("templates/sns/${var.access_level}-topic.tpl")}"
    vars {
        sns_arn = "arn:aws:sns:us-west-1:589690932525:${var.topic_name}"
    }
}

resource "aws_iam_role_policy" "sns_policy" {
    name = "${replace(var.role_name, "-", "_")}_${replace(var.access_level, "-", "_")}_${replace(var.topic_name, "-", "_")}_topic_policy"
    role = "${var.role_name}"
    policy = "${data.template_file.sns_policy_template.rendered}"
}
