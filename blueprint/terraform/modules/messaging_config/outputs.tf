# Messaging Configuration Module Outputs

output "configuration_id" {
  value       = genesyscloud_webdeployments_configuration.account_balance_config.id
  description = "The ID of the web messaging configuration"
}

output "deployment_id" {
  value       = genesyscloud_webdeployments_deployment.account_balance_deployment.id
  description = "The ID of the web messaging deployment"
}

output "deployment_url" {
  value       = "https://apps.${var.region}.pure.cloud/directory/#/admin/integrations/web-messaging"
  description = "URL to view the deployment in Genesys Cloud admin"
}
