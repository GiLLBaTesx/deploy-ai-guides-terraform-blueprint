# Outputs

output "guide_id" {
  value       = module.ai_guide.guide_id
  description = "The ID of the created AI Guide"
}

output "guide_name" {
  value       = module.ai_guide.guide_name
  description = "The name of the AI Guide"
}

output "guide_version_id" {
  value       = module.ai_guide.guide_version_id
  description = "The ID of the guide version"
}

output "data_action_id" {
  value       = module.ai_guide.data_action_id
  description = "The ID of the account balance data action"
}

output "bot_flow_id" {
  value       = module.bot_flow.bot_flow_id
  description = "The ID of the bot flow"
}

output "inbound_message_flow_id" {
  value       = module.inbound_message_flow.flow_id
  description = "The ID of the inbound message flow"
}

output "messaging_deployment_id" {
  value       = module.messaging_config.deployment_id
  description = "The ID of the web messaging deployment"
}

output "deployment_instructions" {
  value       = <<-EOT
    ========================================
    Deployment Complete!
    ========================================
    
    AI Guide: ${module.ai_guide.guide_name}
    Guide ID: ${module.ai_guide.guide_id}
    
    Bot Flow ID: ${module.bot_flow.bot_flow_id}
    Inbound Message Flow ID: ${module.inbound_message_flow.flow_id}
    
    Web Messaging Deployment ID: ${module.messaging_config.deployment_id}
    
    To get the deployment snippet:
    1. Go to Admin > Message > Messenger Deployments
    2. Find deployment: ${module.messaging_config.deployment_id}
    3. Copy the deployment snippet
    4. Add it to your website's HTML
    
    To test the solution:
    1. Open your website with the messenger snippet
    2. Click the messenger button
    3. Type an account number to test the bot
    
    ========================================
  EOT
  description = "Instructions for using the deployed solution"
}
