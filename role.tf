provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "iam" {
  name = "AutoTag"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource aws_iam_policy this {
  name        = "AutoTag"
  description = "Allow to access base resources and trigger transcoder"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "SomeVeryDefaultAndOpenActions",
            "Effect": "Allow",
            "Action": [
                "ec2:*",
                "logs:*",
                "s3:*",
                "lambda:*",
                "cloudwatch:*",
                "s3-object-lambda:*"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "role-attach-policy" {
  role       = aws_iam_role.iam.name
  policy_arn = aws_iam_policy.this.arn
}