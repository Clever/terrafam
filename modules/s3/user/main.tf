variable "name" {
  type = "string"
}

variable "bucket_name" {
  type = "string"
}

variable "access_level" {
  type = "string"
  description = "Can be read, write, or read-and-write"
}

data "aws_iam_policy_document" "read" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [
      "arn:aws:s3:::${var.bucket_name}"
    ]
  }
  statement {
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::${var.bucket_name}/*"
    ]
  }
}

data "aws_iam_policy_document" "write" {
  statement {
    actions = [
      "s3:GetBucketLocation"
    ]
    resources = [
      "arn:aws:s3:::${var.bucket_name}"
    ]
  }
  statement {
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${var.bucket_name}/*"
    ]
  }
}

resource "aws_iam_user_policy" "s3_read_policy" {
    name = "s3_read_${replace(var.bucket_name, "-", "_")}_bucket"
    user = "${var.name}"
    count = "${replace(var.access_level, "-and-write", "") == "read" ? 1 : 0}"
    policy = "${data.aws_iam_policy_document.read.json}"
}

resource "aws_iam_user_policy" "s3_write_policy" {
    name = "s3_write_${replace(var.bucket_name, "-", "_")}_bucket"
    user = "${var.name}"
    count = "${replace(var.access_level, "read-and", "") == "write" ? 1 : 0}"
    policy = "${data.aws_iam_policy_document.write.json}"
}
