# Bot Flow Module Outputs

output "bot_flow_id" {
  value       = genesyscloud_flow.account_balance_bot.id
  description = "The ID of the bot flow"
}

output "bot_flow_name" {
  value       = genesyscloud_flow.account_balance_bot.name
  description = "The name of the bot flow"
}

output "connection_instructions" {
  value       = <<-EOT
    Bot flow deployed successfully!
    
    Flow ID: ${genesyscloud_flow.account_balance_bot.id}
    Flow Name: ${genesyscloud_flow.account_balance_bot.name}
    
    Next steps:
    1. Create an inbound message flow that routes to this bot flow
    2. Configure messaging deployment
    3. Test the complete solution
  EOT
  description = "Instructions for next steps"
}
