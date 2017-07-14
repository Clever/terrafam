{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
                "s3:GetBucketLocation",
                "s3:PutObject"
            ],
            "Resource": "${s3_arn}/*"
        }
    ]
}
