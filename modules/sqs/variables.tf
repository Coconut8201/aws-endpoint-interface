variable "sqs_name" {
  description = "sqs name"
  type        = string
}

variable "tags" {
  description = "tags"
  type        = map(string)
}

variable "vpc_endpoint_id" {
  description = "VPC Endpoint ID for SQS access restriction"
  type        = string
}
