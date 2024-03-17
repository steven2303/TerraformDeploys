resource "aws_lambda_function" "lambda_trigger_glue_job" {
  function_name = "TriggerMatrixModelGlueJob"
  handler       = "TriggerMatrixModelGlueJob.lambda_handler"
  role          = var.lambda_role_arn
  runtime       = "python3.10"

  # Assuming you have a ZIP file with your Lambda code
  filename      = "scripts/TriggerMatrixModelGlueJob.zip"

  # Add necessary environment variables, e.g., the Glue job name
  environment {
    variables = {
      GLUE_JOB_NAME1 = var.glue_job_name1
      GLUE_JOB_NAME2 = var.glue_job_name2
      PREFIXES_JOB1 = jsonencode(var.s3_matrix_models_prefixes_list1)
      PREFIXES_JOB2 = jsonencode(var.s3_matrix_models_prefixes_list2)
    }
  }
}

# Grant S3 permission to invoke the Lambda function
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_trigger_glue_job.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.s3_matrix_models_bucket_name}"
}
