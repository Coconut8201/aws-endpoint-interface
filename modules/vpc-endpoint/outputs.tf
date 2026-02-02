output "vpc_endpoint_id" {
  description = "The ID of the VPC endpoint"
  value       = aws_vpc_endpoint.sqs.id
}

output "vpc_endpoint_arn" {
  description = "The ARN of the VPC endpoint"
  value       = aws_vpc_endpoint.sqs.arn
}

output "vpc_endpoint_dns_entries" {
  description = "The DNS entries for the VPC endpoint"
  value       = aws_vpc_endpoint.sqs.dns_entry
}

output "vpc_endpoint_network_interface_ids" {
  description = "Network interface IDs for the VPC endpoint"
  value       = aws_vpc_endpoint.sqs.network_interface_ids
}

output "vpc_endpoint_state" {
  description = "The state of the VPC endpoint"
  value       = aws_vpc_endpoint.sqs.state
}
