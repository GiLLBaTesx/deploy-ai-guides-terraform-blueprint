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
