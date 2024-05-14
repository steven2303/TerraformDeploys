#output "upload_scripts_arn" {
#  value = [for file in fileset(path.module, "scripts/*") : "arn:aws:s3:::${var.s3_resources_bucket_name}/${file}"]
#}

output "s3_script_file_keys" {
  value = [for obj in aws_s3_object.script_files : obj.key]
}

output "s3_resources_bucket_name" {
  value       = aws_s3_bucket.s3_resources_bucket.bucket
  description = "The name of the S3 bucket for resources"
}