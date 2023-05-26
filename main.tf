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

/*
create two VPCs for dev and prod. Then we create two Lambda functions
one for each environment, with the appropriate VPC configurations
*/

## DEVELOPMENT
resource "aws_vpc" "dev" {
  cidr_block       = var.dev_vpc_cidr
  instance_tenancy = "default"
  tags = {
    Name = "var.easy_dev"
  }
}

resource "aws_subnet" "dev_subnet" {
  vpc_id     = aws_vpc.dev.id
  cidr_block = var.dev_subnets
  tags = {
    Name = "dev-subnet"
  }
}

## PRODUCTION
resource "aws_vpc" "prod" {
  cidr_block       = var.prod_vpc_cidr
  instance_tenancy = "default"
  tags = {
    Name = "var.easy_prod"
  }
}

resource "aws_subnet" "prod_subnet" {
  vpc_id     = aws_vpc.prod.id
  cidr_block = var.prod_subnets
  tags = {
    Name = "prod-subnet"
  }
}

## IAM ROLES
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "iam_for_lambda_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]

    resources = ["*"]
  }
}


## Check if IAM role exist, use it if it does
data "aws_iam_role" "existing" {
  name = "iam_for_lambda"
}

resource "aws_iam_role" "new" {
  count              = try(data.aws_iam_role.existing.name, "iam_for_lambda") == "iam_for_lambda" ? 0 : 1
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy" "iam_for_lambda_policy" {
  name   = "iam_for_lambda_policy"
  role   = try(data.aws_iam_role.existing.id, aws_iam_role.new[0].id)
  policy = data.aws_iam_policy_document.iam_for_lambda_policy.json
}


# BUNDLE
resource "null_resource" "archive" {
  triggers = {
    filename = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "powershell Compress-Archive -Path code/src/hello_lambda.py -DestinationPath function.zip -Force"
  }
}


## SECURITY GROUP
resource "aws_security_group" "lambda_sg_dev" {
  name        = "lambda_sg_dev"
  description = "Security group for development Lambda function"
  vpc_id      = aws_vpc.dev.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lambda_sg_dev"
  }
}

resource "aws_security_group" "lambda_sg_prod" {
  name        = "lambda_sg_prod"
  description = "Security group for production Lambda function"
  vpc_id      = aws_vpc.prod.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lambda_sg_prod"
  }
}


## DEPLOY INFRASTRUCTURE and CODE for DEVELOPMENT and PRODUCTION
data "aws_vpc" "existing_dev" {
  id = "vpc-0540c24020c43066b"
}

data "aws_subnet" "existing_subnet_dev" {
  id = "subnet-0c66fe183f4cdc7f6"
}
resource "aws_lambda_function" "app_server_testing_dev" {
  function_name = "lambda_test_function_dev"
  role          = try(data.aws_iam_role.existing.arn, aws_iam_role.new[0].arn)
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.10"
  vpc_config {
    subnet_ids         = [data.aws_subnet.existing_subnet_dev.id]
    security_group_ids = [aws_security_group.lambda_sg_dev.id]
  }

  filename         = "function.zip"
  source_code_hash = filebase64sha256("function.zip")

  tags = {
    Name = var.easy_dev_vpc
  }

  depends_on = [null_resource.archive]
}

# resource "aws_lambda_function" "app_server_testing_prod" {
#   function_name = "lambda_test_function_prod"
#   role          = try(data.aws_iam_role.existing.arn, aws_iam_role.new[0].arn)
#   handler       = "lambda_function.lambda_handler"
#   runtime       = "python3.10"
#   vpc_config {
#     subnet_ids         = [aws_subnet.prod_subnet.id]
#     security_group_ids = [aws_security_group.lambda_sg_prod.id]
#   }

#   filename         = "function.zip"
#   source_code_hash = filebase64sha256("function.zip")

#   tags = {
#     Name = var.easy_prod_vpc
#   }

#   depends_on = [null_resource.archive]
# }
