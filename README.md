# Terraform Lambda EC2 Auto Tag


A simple Terraform code to deploy EC2/Volume Auto Tag Lambda
The main goal here is:
 - Every new ec2 and volume deployed will be tagged with its own instance creator username
 - format: Owner = $username
 
## Requirements
 - Cloudtrail Enabled
 - https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-create-a-trail-using-the-console-first-time.html

## How it works?
Cloud trail get all AWS API requests 
We have Event Bridge looking for specific request on cloudtrail (ec2 launches)
This event bridge triggers a lambda (written in Python, you can found the lambda source code and detailed explanation on this blog:
https://itnext.io/customized-resources-auto-tagging-in-aws-e3413375ceb4

I didn't code lambda, I just code terraform deployment

## Terraform:
 - Zip lambda code 
 - Module lambda create a lambda function on AWS
 - Create a Role (lambda must be able to tag ec2/volumes)
 - Create a Cloudwatch event rule and target (EventBridge)
 - Create Lambda permissions (Trigger it's added automatically on lambda function)

## Usage
```
 export AWS_ACCESS_KEY_ID = YOUR_ID
 export AWS_SECRET_ACCESS_KEY = YOUR_SECRET
 export AWS_REGION = YOUR_REGION
 terraform init
 terraform plan -out tfplan
 terraform apply tfplan
```
