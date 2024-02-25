resource "aws_kms_key" "kms_audit_log" {
  description             = "KMS key for SQS encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 30
}

resource "aws_kms_key_policy" "kms_audit_log_policy" {
  key_id = aws_kms_key.kms_audit_log.key_id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "Enable IAM User Permissions",
        Effect    = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = aws_kms_key.kms_audit_log.arn
      },
      {
        Sid       = "Allow Lambda to decrypt messages",
        Effect    = "Allow",
        Principal = {
          AWS = var.lambda_role_arn
        },
        Action   = "kms:Decrypt",
        Resource = aws_kms_key.kms_audit_log.arn
      },
      {
        Sid       = "Allow S3 to use the key for encryption",
        Effect    = "Allow",
        Principal = {
           Service = ["s3.amazonaws.com", "sqs.amazonaws.com"]
        },
        Action = [
          "kms:GenerateDataKey",
          "kms:Encrypt",
          "kms:Decrypt"
        ],
        Resource = aws_kms_key.kms_audit_log.arn
      }
    ]
  })
}