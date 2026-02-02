# VPC Endpoint for SQS
resource "aws_vpc_endpoint" "sqs" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.sqs"
  vpc_endpoint_type = "Interface"

  # Associate with private subnet
  subnet_ids = var.subnet_ids

  # Associate with security group
  security_group_ids = var.security_group_ids

  # Enable private DNS
  private_dns_enabled = true

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-sqs-endpoint"
    }
  )
}

# Optional: VPC Endpoint Policy for SQS
resource "aws_vpc_endpoint_policy" "sqs" {
  count = var.enable_endpoint_policy ? 1 : 0

  vpc_endpoint_id = aws_vpc_endpoint.sqs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ]
        Resource = var.sqs_queue_arn != "" ? var.sqs_queue_arn : "*"
      }
    ]
  })
}
