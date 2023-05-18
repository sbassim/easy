variable "aws_region_location" {
  description = "Value of the AWS region"
  type        = string
  default     = "eu-north-1"
}


variable "easy_instance_name" {
  description = "Value of the Name tag for the Lambda Functioin"
  type        = string
  default     = "LambdaServerlessInstance"
}
