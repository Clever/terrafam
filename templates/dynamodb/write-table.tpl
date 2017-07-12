{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:BatchWriteItem",
                "dynamodb:DeleteItem",
                "dynamodb:PutItem",
                "dynamodb:Update*",
                "dynamodb:TagResource",
                "dynamodb:UntagResource"
            ],
            "Resource": [
                "arn:aws:dynamodb:us-west-1:589690932525:table/${table_name}"
            ]
        }
    ]
}
