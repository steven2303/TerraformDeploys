resource "aws_iam_role" "glue_etl_role" {
  name = "glue-etl-execution-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "glue_cloudwatch_logs_policy" {
  name        = "GlueCloudWatchLogsPolicy"
  description = "Allows Glue to create logs in CloudWatch Logs"

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
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws-glue/jobs/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_service_role" {
  role       = aws_iam_role.glue_etl_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_policy_attachment" "glue_cloudwatch_logs_attachment" {
  name       = "glue_cloudwatch_logs_attachment"
  roles      = [aws_iam_role.glue_etl_role.name]
  policy_arn = aws_iam_policy.glue_cloudwatch_logs_policy.arn
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.glue_etl_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

