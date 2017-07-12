{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "sns:Publish",
          "sns:Subscribe"
      ],
      "Resource": "${sns_arn}"
    }
  ]
}
