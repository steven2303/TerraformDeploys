output "private_key" {
  value       = module.ec2.private_key
  sensitive = true
}