output "lambda_trigger_glue_job_arn" {
  value = aws_lambda_function.lambda_trigger_glue_job.arn
}

output "lambda_execute_sql_ddl_arn" {
  value = aws_lambda_function.lambda_execute_sql_ddl.arn
}

output "lambda_invoke_model1_arn" {
  value = aws_lambda_function.lambda_invoke_model1.arn
}

output "lambda_invoke_model2_arn" {
  value = aws_lambda_function.lambda_invoke_model2.arn
}

output "lambda_execute_client_group_prediction_arn" {
  value = aws_lambda_function.lambda_execute_client_group_prediction.arn
}

output "lambda_train_nltk_model_arn" {
  value = aws_lambda_function.lambda_train_nltk_model.arn
}



