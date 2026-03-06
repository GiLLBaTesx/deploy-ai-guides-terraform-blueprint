# Terraform configuration for Genesys Cloud AI Guides
# This example demonstrates deploying a complete AI Guide solution using modular architecture

terraform {
  required_providers {
    genesyscloud = {
      source = "mypurecloud/genesyscloud"
    }
  }
}

# Provider will use environment variables:
# GENESYSCLOUD_OAUTHCLIENT_ID
# GENESYSCLOUD_OAUTHCLIENT_SECRET  
# GENESYSCLOUD_REGION
provider "genesyscloud" {
}

# AI Guide Module
# Creates the AI Guide with version and data action
module "ai_guide" {
  source = "./modules/ai_guide"

  guide_name                  = "Check Account Balance"
  guide_instruction_file      = "account-balance-guide.md"
  input_variable_name         = "account_number"
  input_variable_description  = "Customer's account number"
  output_variable_name        = "current_balance"
  output_variable_description = "Current account balance"
  data_action_name            = "Get Account Balance"
  data_action_label           = "Get Account Balance"
  data_action_description     = "Retrieves customer account balance from backend system"
  integration_id              = var.integration_id
  api_base_url                = var.api_base_url
}

# Bot Flow Module
# Creates a bot flow that calls the AI Guide
module "bot_flow" {
  source = "./modules/bot_flow"

  guide_id             = module.ai_guide.guide_id
  guide_name           = module.ai_guide.guide_name
  input_variable_name  = "account_number"
  output_variable_name = "current_balance"

  depends_on = [module.ai_guide]
}

# Inbound Message Flow Module
# Creates an inbound message flow that routes to the bot flow
module "inbound_message_flow" {
  source = "./modules/inbound_message_flow"

  bot_flow_id   = module.bot_flow.bot_flow_id
  bot_flow_name = module.bot_flow.bot_flow_name

  depends_on = [module.bot_flow]
}

# Messaging Configuration Module
# Creates web messaging configuration and deployment
module "messaging_config" {
  source = "./modules/messaging_config"

  config_name             = "Account Balance Web Messaging - ${var.environment}"
  deployment_name         = "Account Balance Deployment - ${var.environment}"
  inbound_message_flow_id = module.inbound_message_flow.flow_id
  region                  = var.region

  depends_on = [module.inbound_message_flow]
}

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
