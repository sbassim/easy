variable "aws_region_location" {
  description = "Value of the AWS region"
  type        = string
  default     = "eu-north-1"
}


variable "easy_instance_name" {
  description = "Value of the Name tag for the Lambda Function"
  type        = string
  default     = "LambdaServerlessInstance"
}

variable "easy_dev_vpc" {
  description = "Value of the Name tag for the Lambda Function for DEV"
  type        = string
  default     = "DevelopmentServer"
}


variable "easy_prod_vpc" {
  description = "Value of the Name tag for the Lambda Function for PROD"
  type        = string
  default     = "ProductionServer"
}

variable "easy_dev" {
  description = "Value of the Name tag DEV"
  type        = string
  default     = "dev"
}


variable "easy_prod" {
  description = "Value of the Name tag PROD"
  type        = string
  default     = "prod"
}


variable "dev_vpc_cidr" {
  description = "CIDR block for the development VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "dev_subnets" {
  description = "CIDR block for the development subnets"
  type        = string
  default     = "10.0.1.0/24"
}

variable "prod_vpc_cidr" {
  description = "CIDR block for the production VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "prod_subnets" {
  description = "CIDR block for the production subnets"
  type        = string
  default     = "10.1.1.0/24"
}

