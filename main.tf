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
  cidr_block       = var.dev_vpc_cidr
  instance_tenancy = "default"
  tags = {
    Name = "var.easy_dev"
  }
}

resource "aws_subnet" "dev_public_subnet" {
  vpc_id     = aws_vpc.dev.id
  cidr_block = var.dev_public_subnets
  tags = {
    Name = "dev-public-subnet"
  }
}

resource "aws_subnet" "dev_private_subnet" {
  vpc_id     = aws_vpc.dev.id
  cidr_block = var.dev_private_subnets
  tags = {
    Name = "dev-private-subnet"
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

resource "aws_subnet" "prod_public_subnet" {
  vpc_id     = aws_vpc.prod.id
  cidr_block = var.prod_public_subnets
  tags = {
    Name = "prod-public-subnet"
  }
}

resource "aws_subnet" "prod_private_subnet" {
  vpc_id     = aws_vpc.prod.id
  cidr_block = var.prod_private_subnet
  tags = {
    Name = "prod-private-subnet"
  }
}

## PRODUCTION
### GATEWAY

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod.id
}


## PRODUCTION
### ROUTE TABLE

resource "aws_route_table" "prod_public_route_table" {
  vpc_id = aws_vpc.prod.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "prod-public-route-table"
  }
}

resource "aws_route_table" "prod_private_route_table" {
  vpc_id = aws_vpc.prod.id

  tags = {
    Name = "prod-private-route-table"
  }
}


### ASSOCIATIONS
# Route table Association with public or private Subnet
resource "aws_route_table_association" "prod_public_rt_assoc" {
  subnet_id      = aws_subnet.prod_public_subnet.id
  route_table_id = aws_route_table.prod_public_route_table.id
}

resource "aws_route_table_association" "prod_private_rt_assoc" {
  subnet_id      = aws_subnet.prod_private_subnet.id
  route_table_id = aws_route_table.prod_private_route_table.id
}



### NAT

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.prod_public_subnet.id
}

resource "aws_eip" "nat" {
  vpc = true
}


## LAMBDA

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


## DEPLOY INFRASTRUCTURE and CODE
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
