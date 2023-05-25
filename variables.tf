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
  description = "Value of "
  type        = string
  default     = "10.0.0.0/16"

}

variable "dev_public_subnets" {
  description = "Value of "
  type        = string
  default     = "10.1.1.0/24"

}

variable "dev_private_subnets" {
  description = "Value of "
  type        = string
  default     = "10.1.2.0/24"

}

variable "prod_vpc_cidr" {
  description = "Value of "
  type        = string
  default     = "10.1.0.0/16"

}

variable "prod_public_subnets" {
  description = "Value of "
  type        = string
  default     = "10.0.1.0/24"

}

variable "prod_private_subnets" {
  description = "Value of "
  type        = string
  default     = "10.0.2.0/24"
}
