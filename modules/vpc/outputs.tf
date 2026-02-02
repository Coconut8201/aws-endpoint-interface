output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.this.cidr_block
}

output "subnet_id" {
  description = "Subnet ID"
  value       = aws_subnet.sbt.id
}

output "subnet_cidr" {
  description = "Subnet CIDR block"
  value       = aws_subnet.sbt.cidr_block
}

output "subnet_az" {
  description = "Subnet availability zone"
  value       = aws_subnet.sbt.availability_zone
}

output "route_table_id" {
  description = "Route table ID"
  value       = aws_route_table.rtb.id
}

output "default_security_group_id" {
  description = "Default security group ID"
  value       = aws_security_group.sg.id
}
