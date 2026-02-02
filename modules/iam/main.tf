# IAM Role for EC2 to access SQS
resource "aws_iam_role" "ec2_sqs_role" {
  name = "${var.project_name}-ec2-sqs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-ec2-sqs-role"
    }
  )
}

# IAM Policy for SQS access
resource "aws_iam_role_policy" "sqs_policy" {
  name = "${var.project_name}-sqs-policy"
  role = aws_iam_role.ec2_sqs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ]
        Resource = var.sqs_queue_arn
      }
    ]
  })
}

# Instance Profile to attach to EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_sqs_role.name

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-ec2-profile"
    }
  )
}
