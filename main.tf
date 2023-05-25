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

## LAMBDA

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}


## CODE
### bundle code

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


## DEPLOY INFRASTRUCTURE and CODE

## DEVELOPMENT

resource "aws_lambda_function" "app_server_testing_dev" {
  function_name = "lambda_test_function_dev"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.10"
  vpc_config {
    subnet_ids         = [aws_subnet.dev_subnet.id]
    security_group_ids = [aws_security_group.lambda_sg_dev.id]
  }

  filename         = "function.zip"
  source_code_hash = filebase64sha256("function.zip")

  tags = {
    Name = var.easy_dev_vpc
  }

  depends_on = [null_resource.archive]
}

## PRODUCTION

resource "aws_lambda_function" "app_server_testing_prod" {
  function_name = "lambda_test_function_prod"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.10"
  vpc_config {
    subnet_ids         = [aws_subnet.prod_subnet.id]
    security_group_ids = [aws_security_group.lambda_sg_prod.id]
  }

  filename         = "function.zip"
  source_code_hash = filebase64sha256("function.zip")

  tags = {
    Name = var.easy_prod_vpc
  }

  depends_on = [null_resource.archive]
}
