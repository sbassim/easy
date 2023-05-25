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
