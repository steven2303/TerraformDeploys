resource "aws_s3_bucket" "s3_audit_logs_processed_bucket" {
  bucket = var.s3_audit_logs_processed_bucket_name
}

resource "aws_s3_bucket_public_access_block" "s3_audit_logs_processed_bucket_public_access_block" {
  bucket = aws_s3_bucket.s3_audit_logs_processed_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "s3_audit_logs_processed_bucket_policy" {
  bucket = aws_s3_bucket.s3_audit_logs_processed_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "s3_audit_logs_processed_bucket_policy",
    Statement = [
      {
        Sid       = "HTTPSOnly",
        Effect    = "Deny",
        Principal = "*",
        Action    = "s3:*",
        Resource  = [
          aws_s3_bucket.s3_audit_logs_processed_bucket.arn,
          "${aws_s3_bucket.s3_audit_logs_processed_bucket.arn}/*",
        ],
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
    ]
  })
}

resource "aws_s3_bucket" "s3_resources_bucket" {
  bucket = var.s3_resources_bucket_name
}

resource "aws_s3_bucket_public_access_block" "s3_resources_bucket_public_access_block" {
  bucket = aws_s3_bucket.s3_resources_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "s3_resources_bucket_policy" {
  bucket = aws_s3_bucket.s3_resources_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "s3_resources_bucket_policy",
    Statement = [
      {
        Sid       = "HTTPSOnly",
        Effect    = "Deny",
        Principal = "*",
        Action    = "s3:*",
        Resource  = [
          aws_s3_bucket.s3_resources_bucket.arn,
          "${aws_s3_bucket.s3_resources_bucket.arn}/*",
        ],
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
    ]
  })
}

resource "null_resource" "upload_scripts" {
  depends_on = [
    aws_s3_bucket.s3_resources_bucket,
    aws_s3_bucket_public_access_block.s3_resources_bucket_public_access_block,
    aws_s3_bucket_policy.s3_resources_bucket_policy
  ]

  provisioner "local-exec" {
  command = <<EOT
    Get-ChildItem -Path "scripts\\" -File | ForEach-Object {
      aws s3 cp $_.FullName s3://${aws_s3_bucket.s3_resources_bucket.bucket}/scripts/$($_.Name)
    }
    aws s3api put-object --bucket ${aws_s3_bucket.s3_resources_bucket.bucket} --key consultas-athena/ 
  EOT
  interpreter = ["PowerShell", "-Command"]
  }
}

#provisioner "local-exec" {
#    command = <<EOT
#      for file in scripts/*; do
#        aws s3 cp "$file" "s3://${aws_s3_bucket.s3_buckets[var.s3_resources_bucket_name].bucket}/scripts/$(basename "$file")"
#      done
#      aws s3api put-object --bucket ${aws_s3_bucket.s3_buckets[var.s3_resources_bucket_name].bucket} --key consultas-athena/ 
#    EOT
#    interpreter = ["bash", "-c"]
#  }

resource "aws_s3_bucket_notification" "s3_sftp_audit_log_bucket_notification" {
  bucket = var.sftp_audit_log_bucket_name
  
  dynamic "lambda_function" {
    for_each = var.sftp_audit_log_bucket_prefixes

    content {
      lambda_function_arn = var.raw_sftp_audit_log_lambda_queue_arn
      events              = ["s3:ObjectCreated:*"]
      filter_prefix       = lambda_function.value
    }
  }
}

resource "aws_s3_bucket_notification" "s3_audit_log_bucket_notification" {
  bucket = var.audit_log_landing_bucket_name
  queue {
    queue_arn     = var.audit_log_sqs_queue_arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = var.audit_log_landing_bucket_prefix
  }
  lambda_function {
    lambda_function_arn = var.lambda_pgmmaster_log_processor_function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = var.pgmmaster_log_processor_bucket_prefix
  }
}
