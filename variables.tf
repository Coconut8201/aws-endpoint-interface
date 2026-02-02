variable "vpc_cidr_block" {
  description = "vpc cidr"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidrs_block" {
  description = "CIDR blocks for network VPC private subnets"
  type        = string
  default     = "10.0.1.0/24"
}

variable "az" {
  description = "alivanle zone"
  type        = string
  default     = "ap-northeast-1a"
}

variable "vpc_name" {
  description = "VPC Show Name"
  type        = string
  default     = "coco-endpoint-vpc"
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "ap-northeast-1"
}

variable "admin_principal_arn" {
  description = "Admin IAM principal ARN to exclude from deny policy"
  type        = string
  default     = "arn:aws:iam::858714464329:user/coco-river"
}

variable "sqs_name" {
  description = "SQS Queue Name"
  type        = string
  default     = "coco-endpoint-sqs"
}

variable "enable_endpoint_policy" {
  description = "Enable VPC endpoint policy for SQS"
  type        = bool
  default     = false
}
