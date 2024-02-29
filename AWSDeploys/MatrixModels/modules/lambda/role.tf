resource "aws_iam_role" "lambda_role" {
  name = "lambda-${var.project_name}-role"
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
  name        = "cloudwatch-logs-${var.project_name}-policy"
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
  name       = "lambda-cloudwatch-logs-${var.project_name}-attachment"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.lambda_cloudwatch_logs_policy.arn
}

resource "aws_iam_policy" "lambda_s3_access_policy" {
  name        = "lambda-s3-access-${var.project_name}-policy"
  description = "Permite a la función Lambda acceder a s3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
        {
            "Action": "s3:*",
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::${var.s3_matrix_models_bucket_name}",
                "arn:aws:s3:::${var.s3_matrix_models_bucket_name}/*"
            ]
        }
      ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_access_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_s3_access_policy.arn
}

resource "aws_iam_policy" "lambda_secrets_manager_access_policy" {
  name        = "lambda-secrets-manager-access-${var.project_name}-policy"
  description = "Policy to allow Lambda function to access Secrets Manager secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource  = [
          var.secrets_manager_secret_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_secrets_manager_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_secrets_manager_access_policy.arn
}

resource "aws_iam_policy" "lambda_aurora_access_policy" {
  name        = "lambda-aurora-access-${var.project_name}-policy"
  description = "Policy to allow Lambda function to access Aurora RDS cluster"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = [
          "rds:DescribeDBClusters",
          "rds:ExecuteStatement",
          "rds:BatchExecuteStatement",
          "rds:BeginTransaction",
          "rds:CommitTransaction",
          "rds:RollbackTransaction"
        ]
        Resource  = [
          var.aurora_cluster_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_aurora_access_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_aurora_access_policy.arn
}

resource "aws_iam_policy" "lambda_vpc_access_policy" {
  name        = "lambda-vpc-access-${var.project_name}-policy"
  description = "Policy to allow Lambda function to manage network interfaces in a specific VPC"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Resource  =  "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_vpc_access_policy.arn
}

