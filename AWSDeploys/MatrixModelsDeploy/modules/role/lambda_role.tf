resource "aws_iam_role" "lambda_role" {
  name =   "ue1seg${var.stage_name}rolflm001"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = ["lambda.amazonaws.com", "glue.amazonaws.com"]
        },
      },
    ],
  })
}

resource "aws_iam_policy" "lambda_cloudwatch_logs_policy" {
  name        = "ue1seg${var.stage_name}polflm001"
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

resource "aws_iam_policy_attachment" "lambda_cloudwatch_logs_policy_attachment" {
  name       = "ue1seg${var.stage_name}polflm001-attachment"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.lambda_cloudwatch_logs_policy.arn
}

resource "aws_iam_policy" "lambda_s3_access_policy" {
  name        = "ue1seg${var.stage_name}polflm002"
  description = "Permite a la función Lambda acceder a s3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
        {
            "Action": "s3:*",
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::${var.s3_matrix_models_bucket_name}",
                "arn:aws:s3:::${var.s3_matrix_models_bucket_name}/*",
                "arn:aws:s3:::${var.s3_resources_bucket_name}",
                "arn:aws:s3:::${var.s3_resources_bucket_name}/*"
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
  name        = "ue1seg${var.stage_name}polflm003"
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

resource "aws_iam_role_policy_attachment" "lambda_secrets_manager_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_secrets_manager_access_policy.arn
}

resource "aws_iam_policy" "lambda_aurora_access_policy" {
  name        = "ue1seg${var.stage_name}polflm004"
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

resource "aws_iam_role_policy_attachment" "lambda_aurora_access_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_aurora_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}


# GLUE

resource "aws_iam_policy" "glue_connection_policy" {
  name   = "ue1seg${var.stage_name}polflm005"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "glue:GetConnection"
        Resource = [
          "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:catalog",  
          "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:connection/${var.glue_connection_name}" 
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_connection_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.glue_connection_policy.arn
}


resource "aws_iam_role_policy_attachment" "glue_service_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_policy" "lambda_invoke_policy" {
  name        = "ue1seg${var.stage_name}polflm007"
  description = "Policy to allow invocation of specific Lambda functions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "lambda:InvokeFunction"
        Resource = [
          var.lambda_invoke_model2_arn,
          var.lambda_invoke_model1_arn,
          var.lambda_train_nltk_model_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_invoke_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_invoke_policy.arn
}