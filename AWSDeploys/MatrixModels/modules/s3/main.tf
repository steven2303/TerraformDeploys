resource "aws_s3_bucket_notification" "s3_to_lambda_trigger" {
  bucket = var.s3_matrix_models_bucket_name

  lambda_function {
    lambda_function_arn = var.lambda_s3_to_glue_trigger_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = var.s3_prefix_trigger
  }
}

/* resource "aws_s3_bucket_notification" "s3_to_lambda_trigger2" {
  bucket = var.s3_matrix_models_bucket_name
  
  dynamic "lambda_function" {
    for_each = var.s3_matrix_models_prefix_list2

    content {
      lambda_function_arn = var.lambda_s3_to_glue_trigger_arn2
      events              = ["s3:ObjectCreated:*"]
      filter_prefix       = lambda_function.value
    }
  }

  #Ydepends_on = [aws_lambda_function.my_lambda]
} */