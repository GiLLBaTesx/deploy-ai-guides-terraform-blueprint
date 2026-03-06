# Bot Flow Module
# Creates a bot flow that calls the AI Guide

# Create the bot flow
resource "genesyscloud_flow" "account_balance_bot" {
  filepath = "${path.module}/bot-flow.yaml"

  substitutions = {
    guide_id             = var.guide_id
    guide_name           = var.guide_name
    input_variable_name  = var.input_variable_name
    output_variable_name = var.output_variable_name
  }
}
