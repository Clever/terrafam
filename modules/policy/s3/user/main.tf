variable "user_name" {
  type = "string"
}

variable "bucket_name" {
  type = "string"
}

variable "access_level" {
  type = "string"
  description = "Can be read, write, or read-and-write"
}

data "template_file" "s3_policy_template" {
    template = "${file("templates/s3/${var.access_level}-bucket.tpl")}"
    vars {
        s3_arn = "arn:aws:s3:::${var.bucket_name}"
    }
}

resource "aws_iam_user_policy" "s3_policy" {
    name = "${var.user_name}_${var.access_level}_${var.bucket_name}_bucket_policy"
    user = "${var.user_name}"
    policy = "${data.template_file.s3_policy_template.rendered}"
}
