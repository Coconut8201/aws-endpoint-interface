# VPC settings
module "coco-endpoint-vpc" {
  source = "./modules/vpc"

  vpc_name          = var.vpc_name
  vpc_cidr_block    = var.vpc_cidr_block
  subnet_cidr_block = var.subnet_cidrs_block
  az                = var.az
  region            = var.region

  tags = {
    Name = var.vpc_name
  }
}

# VPC Endpoint settings for SQS (必須先建立才能設定 SQS policy)
module "vpc-endpoint" {
  source = "./modules/vpc-endpoint"

  vpc_id             = module.coco-endpoint-vpc.vpc_id
  vpc_name           = var.vpc_name
  region             = var.region
  subnet_ids         = [module.coco-endpoint-vpc.subnet_id]
  security_group_ids = [module.coco-endpoint-vpc.default_security_group_id]

  # 暫時不設定 endpoint policy，改用 SQS resource policy
  enable_endpoint_policy = false
  sqs_queue_arn          = ""

  tags = {
    Name      = "${var.vpc_name}-sqs-endpoint"
    ManagedBy = "terraform"
  }
}

# SQS settings (依賴 VPC Endpoint)
module "sqs" {
  source = "./modules/sqs"

  sqs_name                   = var.sqs_name
  vpc_endpoint_id            = module.vpc-endpoint.vpc_endpoint_id
  enable_vpc_endpoint_policy = false # 暫時關閉，測試成功後再啟用

  tags = {
    Name      = var.sqs_name
    ManagedBy = "terraform"
  }
}

# IAM settings for EC2 to access SQS
module "iam" {
  source = "./modules/iam"

  project_name  = var.vpc_name
  sqs_queue_arn = module.sqs.queue_arn

  tags = {
    Name      = "${var.vpc_name}-iam"
    ManagedBy = "terraform"
  }
}
