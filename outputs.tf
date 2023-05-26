output "instance_id" {
  description = "ID of the lambda function"
  value       = try(data.aws_iam_role.existing.id, aws_iam_role.new[0].id)
}
