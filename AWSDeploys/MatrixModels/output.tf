output "invoke_url_api1" {
  value = module.customer_products_recommender_and_profile_api.invoke_url_api1
}

output "cross_account_api_access_role_name" {
  value       = module.role.cross_account_api_access_role_name
}

output "account_id" {
  value       = module.role.account_id
}