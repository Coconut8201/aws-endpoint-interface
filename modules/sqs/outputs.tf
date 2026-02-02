output "queue_id" {
  description = "The URL of the SQS queue"
  value       = aws_sqs_queue.standard_queue.id
}

output "queue_arn" {
  description = "The ARN of the SQS queue"
  value       = aws_sqs_queue.standard_queue.arn
}

output "queue_name" {
  description = "The name of the SQS queue"
  value       = aws_sqs_queue.standard_queue.name
}

output "queue_url" {
  description = "The URL of the SQS queue"
  value       = aws_sqs_queue.standard_queue.url
}
