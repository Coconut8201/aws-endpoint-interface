variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "subnet_ids" {
  description = "List of subnet IDs for the VPC endpoint"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the VPC endpoint"
  type        = list(string)
}

variable "enable_endpoint_policy" {
  description = "Whether to enable VPC endpoint policy"
  type        = bool
  default     = false
}

variable "sqs_queue_arn" {
  description = "ARN of the SQS queue for endpoint policy"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
