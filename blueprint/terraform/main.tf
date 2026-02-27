# Terraform configuration for Genesys Cloud AI Guides
# This example demonstrates deploying an AI Guide using CX as Code

terraform {
  required_providers {
    genesyscloud = {
      source  = "mypurecloud/genesyscloud"
    }
  }
}

# Provider will use environment variables:
# GENESYSCLOUD_OAUTHCLIENT_ID
# GENESYSCLOUD_OAUTHCLIENT_SECRET  
# GENESYSCLOUD_REGION
provider "genesyscloud" {
}

# Create an AI Guide container
resource "genesyscloud_guide" "account_balance_guide" {
  name = "Check Account Balance"
}

# Create a version of the guide with instructions and variables
resource "genesyscloud_guide_version" "account_balance_v1" {
  guide_id    = genesyscloud_guide.account_balance_guide.id
  instruction = file("${path.module}/guides/account-balance-guide.md")

  # Input variable from bot flow
  variables {
    name        = "account_number"
    type        = "String"
    scope       = "Input"
    description = "Customer's account number"
  }

  # Output variable to pass back to flow
  variables {
    name        = "current_balance"
    type        = "String"
    scope       = "Output"
    description = "Current account balance"
  }

  # Reference to data action
  resources {
    data_action {
      data_action_id = genesyscloud_integration_action.get_account_balance.id
      label          = "Get Account Balance"
      description    = "Retrieves customer account balance from backend system"
    }
  }
}

# Data action for retrieving account balance
resource "genesyscloud_integration_action" "get_account_balance" {
  name           = "Get Account Balance"
  category       = "Account Management"
  integration_id = var.integration_id

  contract_input = jsonencode({
    type = "object"
    properties = {
      accountNumber = {
        type        = "string"
        description = "The account number to look up"
      }
    }
    required = ["accountNumber"]
  })

  contract_output = jsonencode({
    type = "object"
    properties = {
      balance = {
        type        = "string"
        description = "Current account balance"
      }
      currency = {
        type        = "string"
        description = "Currency code (e.g., USD)"
      }
      lastUpdated = {
        type        = "string"
        description = "Last update timestamp"
      }
    }
  })

  config_request {
    request_url_template = "${var.api_base_url}/accounts/$${input.accountNumber}/balance"
    request_type         = "GET"
    request_template     = "$${input.rawRequest}"
  }

  config_response {
    translation_map = {
      balance     = "$.balance.amount"
      currency    = "$.balance.currency"
      lastUpdated = "$.lastUpdated"
    }
    success_template = "$${rawResult}"
  }
}

# Outputs
output "guide_id" {
  value       = genesyscloud_guide.account_balance_guide.id
  description = "The ID of the created AI Guide"
}

output "guide_name" {
  value       = genesyscloud_guide.account_balance_guide.name
  description = "The name of the AI Guide"
}

output "guide_version_id" {
  value       = genesyscloud_guide_version.account_balance_v1.id
  description = "The ID of the guide version"
}

output "data_action_id" {
  value       = genesyscloud_integration_action.get_account_balance.id
  description = "The ID of the account balance data action"
}
