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

resource "aws_s3_bucket_notification" "s3_to_lambda_trigger" {
  bucket = var.s3_matrix_models_bucket_name

  lambda_function {
    lambda_function_arn = var.lambda_s3_to_glue_trigger_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = var.s3_prefix_trigger
  }
  lambda_function {
    lambda_function_arn = var.lambda_s3_to_glue_trigger_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = var.s3_prefix_trigger_preprocessing 
  }
  lambda_function {
    lambda_function_arn = var.lambda_invoke_model1_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = var.prefix_sku_catalog
  }
}

resource "aws_s3_bucket_notification" "s3_to_lambda_trigger_model" {
  bucket = var.s3_resources_bucket_name

  lambda_function {
    lambda_function_arn = var.lambda_invoke_model1_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = var.s3_prefix_trigger_model
  }
}

resource "aws_s3_object" "script_files" {
  for_each = fileset("scripts/", "**/*")

  bucket = aws_s3_bucket.s3_resources_bucket.id
  key    = "scripts/${each.value}"
  source = "scripts/${each.value}"

  etag = filemd5("scripts/${each.value}")
}