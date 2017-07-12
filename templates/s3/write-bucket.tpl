{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketLocation",
                "s3:PutObject"
            ],
            "Resource": [
                "${s3_arn}/*",
                "${s3_arn}"
            ]
        }
    ]
}
