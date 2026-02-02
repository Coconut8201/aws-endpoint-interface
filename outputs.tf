# VPC Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.coco-endpoint-vpc.vpc_id
}

output "subnet_id" {
  description = "The ID of the private subnet"
  value       = module.coco-endpoint-vpc.subnet_id
}

output "security_group_id" {
  description = "The ID of the default security group"
  value       = module.coco-endpoint-vpc.default_security_group_id
}

# SQS Outputs
output "sqs_queue_url" {
  description = "The URL of the SQS queue"
  value       = module.sqs.queue_url
}

output "sqs_queue_arn" {
  description = "The ARN of the SQS queue"
  value       = module.sqs.queue_arn
}

output "sqs_queue_name" {
  description = "The name of the SQS queue"
  value       = module.sqs.queue_name
}

# VPC Endpoint Outputs
output "vpc_endpoint_id" {
  description = "The ID of the VPC endpoint for SQS"
  value       = module.vpc-endpoint.vpc_endpoint_id
}

output "vpc_endpoint_dns_entries" {
  description = "The DNS entries for the VPC endpoint"
  value       = module.vpc-endpoint.vpc_endpoint_dns_entries
}

output "vpc_endpoint_state" {
  description = "The state of the VPC endpoint"
  value       = module.vpc-endpoint.vpc_endpoint_state
}

# IAM Outputs
output "ec2_instance_profile_name" {
  description = "Name of the IAM instance profile for EC2"
  value       = module.iam.instance_profile_name
}

output "ec2_instance_profile_arn" {
  description = "ARN of the IAM instance profile for EC2"
  value       = module.iam.instance_profile_arn
}

output "ec2_iam_role_name" {
  description = "Name of the IAM role for EC2"
  value       = module.iam.role_name
}
