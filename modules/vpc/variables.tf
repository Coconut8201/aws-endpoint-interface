variable "vpc_name" {
  description = "VPC Show Name"
  type        = string
}

variable "vpc_cidr_block" {
  description = "vpc cidr"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "subnet_cidr_block" {
  description = "Subnet CIDR Block"
  type        = string
}

variable "az" {
  description = "Availability Zone"
  type        = string
  default     = "ap-northeast-1a"
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "ap-northeast-1"
}
