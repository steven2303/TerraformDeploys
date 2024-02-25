output "s3_audit_logs_processed_bucket_name" {
  value = aws_s3_bucket.s3_audit_logs_processed_bucket.bucket
}

output "upload_scripts_arn" {
  value = [for file in fileset(path.module, "scripts/*") : "arn:aws:s3:::${aws_s3_bucket.s3_resources_bucket.bucket}/${file}"]
}