output "instance_id" {
  description = "ID of the lambda function"
  value       = aws_iam_role.iam_for_lambda.id
}
