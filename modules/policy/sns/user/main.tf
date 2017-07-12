variable "user_name" {
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

resource "aws_iam_user_policy" "sns_policy" {
    name = "${var.user_name}_${var.access_level}_${var.topic_name}_topic_policy"
    user = "${var.user_name}"
    policy = "${data.template_file.sns_policy_template.rendered}"
}
