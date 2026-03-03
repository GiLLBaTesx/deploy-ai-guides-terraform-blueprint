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
  description = "The guide ID to use in bot flow configuration"
}

output "bot_flow_connection_instructions" {
  value       = module.bot_flow.connection_instructions
  description = "Instructions for connecting the guide to a bot flow"
}
