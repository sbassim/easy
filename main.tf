terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-north-1"
}


resource "aws_vpc" "Dev" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "var.easy_dev"
  }
}

resource "aws_vpc" "Pro" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "var.easy_pro"
  }
}


/* 
creates subnets, a route table, and a NAT Gateway for private subnets for connections
without a routable IP address for each resource
*/

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

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


resource "null_resource" "archive" {
  triggers = {
    filename = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "powershell Compress-Archive -Path code/src/hello_lambda.py -DestinationPath function.zip -Force"
  }
}

resource "aws_lambda_function" "app_server_testing" {
  function_name = "lambda_test_function"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.10"

  filename         = "function.zip"
  source_code_hash = filebase64sha256("function.zip")

  tags = {
    Name = "var.easy_instance_name"
  }

  depends_on = [null_resource.archive]
}
