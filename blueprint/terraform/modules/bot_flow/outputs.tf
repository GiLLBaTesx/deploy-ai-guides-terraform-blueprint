# Bot Flow Module Outputs

output "bot_flow_id" {
  value       = var.guide_id
  description = "The guide ID to use in bot flow configuration"
}

output "connection_instructions" {
  value       = local.bot_flow_instructions
  description = "Instructions for connecting the guide to a bot flow"
}
