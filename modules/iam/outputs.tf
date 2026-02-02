output "instance_profile_name" {
  description = "Name of the IAM instance profile to attach to EC2"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "instance_profile_arn" {
  description = "ARN of the IAM instance profile"
  value       = aws_iam_instance_profile.ec2_profile.arn
}

output "role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.ec2_sqs_role.name
}

output "role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.ec2_sqs_role.arn
}
