
data archive_file lambda {
  type        = "zip"
  #source_file = "index.js"
  source_dir  = "./lambdaAutoTag"
  output_path = "lambdaAutoTag.zip"
}

module lambda {
  source = "github.com/terraform-module/terraform-aws-lambda?ref=v2.9.0"

  function_name  = var.lambda_name
  #filename       = lambdaAutoTag.py
  filename       = data.archive_file.lambda.output_path
  description    = "Auto Tag Ec2 Resources with Key=Owner Value=Username"
  handler        = "lambdaAutoTag.lambda_handler"
  runtime        = "python3.6"
  memory_size    = "128"
  concurrency    = 10
  role_arn       = aws_iam_role.iam.arn

  tags = {
    Environment = var.env
    Name = "Lambda Auto Ec2 Auto Tag"
  }
}

data "aws_lambda_function" "lambda" {
  depends_on = [
    module.lambda
  ]
  function_name = var.lambda_name
}

## Event Bridge ####
resource "aws_cloudwatch_event_rule" "AutoTag" {
  depends_on = [
    module.lambda
  ]
  name = "AutoTag"
  event_pattern = <<PATTERN
  {
     "source": ["aws.ec2"],
     "detail-type": ["AWS API Call via CloudTrail"],
     "detail": {
       "eventSource": ["ec2.amazonaws.com"]
     }
   }
   PATTERN
}

resource "aws_cloudwatch_event_target" "AutoTag" {
  depends_on = [
    module.lambda
  ]
  rule      = aws_cloudwatch_event_rule.AutoTag.name
  target_id = data.aws_lambda_function.lambda.id
  arn       = data.aws_lambda_function.lambda.arn
}

#################
resource "aws_lambda_permission" "allow_cloudwatch" {
  depends_on = [
    module.lambda
  ]
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.AutoTag.arn
}