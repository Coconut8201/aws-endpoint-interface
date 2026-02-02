# 標準佇列
resource "aws_sqs_queue" "standard_queue" {
  name                       = var.sqs_name
  delay_seconds              = 0      # 延遲傳遞時間(0-900秒)
  max_message_size           = 262144 # 最大訊息大小(bytes)
  message_retention_seconds  = 345600 # 訊息保留時間(60秒-14天)
  receive_wait_time_seconds  = 10     # Long polling 等待時間
  visibility_timeout_seconds = 30     # 可見性超時時間

  tags = {
    Name      = var.sqs_name
    ManagedBy = "terraform"
  }
}

# SQS Queue Policy - 只允許從 VPC Endpoint 存取
resource "aws_sqs_queue_policy" "vpc_endpoint_only" {
  queue_url = aws_sqs_queue.standard_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyAllNotFromVPCEndpoint"
        Effect    = "Deny"
        Principal = "*"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueUrl"
        ]
        Resource = aws_sqs_queue.standard_queue.arn
        Condition = {
          StringNotEquals = {
            "aws:SourceVpce" = var.vpc_endpoint_id
          }
        }
      }
    ]
  })
}
