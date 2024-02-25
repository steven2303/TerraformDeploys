resource "aws_iam_role" "lambda_role" {
  name = "fastlayer-logs-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_iam_policy" "lambda_cloudwatch_logs_policy" {
  name        = "LambdaCloudWatchLogsPolicy"
  description = "Allows Lambda to create logs in CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_cloudwatch_logs_attachment" {
  name       = "lambda_cloudwatch_logs_attachment"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.lambda_cloudwatch_logs_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_glue_service_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "stepfunctions_full_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSStepFunctionsConsoleFullAccess"
}

resource "aws_iam_policy" "lambda_s3_sftp_audit_log_copy_policy" {
  name        = "LambdaS3SFTPAuditLogCopyPolicy"
  description = "Permite a la función Lambda copiar archivos de bucket1 a bucket2."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
        {
            "Action": "s3:*",
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::${var.sftp_audit_log_bucket_name}",
                "arn:aws:s3:::${var.sftp_audit_log_bucket_name}/*",
                "arn:aws:s3:::${var.audit_log_landing_bucket_name}",
                "arn:aws:s3:::${var.audit_log_landing_bucket_name}/*",
                "arn:aws:s3:::${var.pgmmaster_log_bucket_name}",
                "arn:aws:s3:::${var.pgmmaster_log_bucket_name}/*"
            ]
        }
      ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_sftp_audit_log_copy_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_s3_sftp_audit_log_copy_policy.arn
}

resource "aws_iam_policy" "lambda_sqs_kms_policy" {
  name        = "LambdaSQSKMSPolicy"
  description = "Permite a la función Lambda recibir y eliminar mensajes de SQS y desencriptar con KMS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = var.audit_log_sqs_queue_arn
      },
      {
        Effect   = "Allow",
        Action   = "kms:Decrypt",
        Resource = var.kms_audit_log_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_kms_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_sqs_kms_policy.arn
}