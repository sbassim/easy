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
creates subnets, a route table, and a NAT Gateway for private subnets for connections
without a routable IP address for each resource
*/

## DEVELOPMENT
resource "aws_vpc" "dev" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "var.easy_dev"
  }
}

resource "aws_subnet" "dev_public_subnet" {
  vpc_id     = aws_vpc.dev.id
  cidr_block = "10.1.1.0/24"
  tags = {
    Name = "dev-public-subnet"
  }
}

resource "aws_subnet" "dev_private_subnet" {
  vpc_id     = aws_vpc.dev.id
  cidr_block = "10.1.2.0/24"
  tags = {
    Name = "dev-private-subnet"
  }
}

## PRODUCTION
resource "aws_vpc" "prod" {
  cidr_block       = "10.1.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "var.easy_prod"
  }
}

resource "aws_subnet" "prod_public_subnet" {
  vpc_id     = aws_vpc.prod.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "prod-public-subnet"
  }
}

resource "aws_subnet" "prod_private_subnet" {
  vpc_id     = aws_vpc.prod.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "prod-private-subnet"
  }
}

## PRODUCTION
### GATEWAY

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod.id
}



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
