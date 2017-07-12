variable "role_name" {
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

resource "aws_iam_role_policy" "s3_policy" {
    name = "${replace(var.role_name, "-", "_")}_${replace(var.access_level, "-", "_")}_${replace(var.bucket_name, "-", "_")}_bucket_policy"
    role = "${var.role_name}"
    policy = "${data.template_file.s3_policy_template.rendered}"
}
