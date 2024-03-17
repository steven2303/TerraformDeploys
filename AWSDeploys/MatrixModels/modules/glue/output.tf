output "glue_connection_name" {
  value = aws_glue_connection.fast_layer_aurora_connection.name
}

output "glue_job_name1" {
  value = aws_glue_job.glue_matrix_models_to_rds_etl_job1.name
}

output "glue_job_name2" {
  value = aws_glue_job.glue_matrix_models_to_rds_etl_job2.name
}