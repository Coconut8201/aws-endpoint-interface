variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "sqs_queue_arn" {
  description = "ARN of the SQS queue to grant access to"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
