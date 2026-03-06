# AI Guide Module
# Creates an AI Guide with version and data action

# Create an AI Guide container
resource "genesyscloud_guide" "guide" {
  name = var.guide_name
}

# Create a version of the guide with instructions and variables
resource "genesyscloud_guide_version" "version" {
  guide_id    = genesyscloud_guide.guide.id
  instruction = file("${path.module}/${var.guide_instruction_file}")

  # Input variable from bot flow
  variables {
    name        = var.input_variable_name
    type        = "String"
    scope       = "Input"
    description = var.input_variable_description
  }

  # Output variable to pass back to flow
  variables {
    name        = var.output_variable_name
    type        = "String"
    scope       = "Output"
    description = var.output_variable_description
  }

  # Reference to data action
  resources {
    data_action {
      data_action_id = genesyscloud_integration_action.data_action.id
      label          = var.data_action_label
      description    = var.data_action_description
    }
  }
}

# Data action for retrieving account balance
resource "genesyscloud_integration_action" "data_action" {
  name           = var.data_action_name
  category       = var.data_action_category
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
