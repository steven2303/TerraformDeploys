resource "aws_s3_bucket_notification" "s3_to_lambda_trigger" {
  bucket = var.s3_matrix_models_bucket_name

  lambda_function {
    lambda_function_arn = var.lambda_s3_to_glue_trigger_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = var.s3_prefix_trigger
  }
}
