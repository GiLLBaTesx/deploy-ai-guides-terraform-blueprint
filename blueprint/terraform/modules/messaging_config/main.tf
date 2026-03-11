# Messaging Configuration Module
# Creates web messaging configuration and deployment

# Create web messaging configuration
resource "genesyscloud_webdeployments_configuration" "account_balance_config" {
  name        = var.config_name
  description = "Web messaging configuration for account balance bot"
  languages   = ["en-us"]

  default_language = "en-us"

  messenger {
    enabled = true

    launcher_button {
      visibility = "On"
    }

    styles {
      primary_color = "#0078D4"
    }

    file_upload {
      mode {
        file_types       = []
        max_file_size_kb = 0
      }
    }
  }

  cobrowse {
    enabled = false
  }

  journey_events {
    enabled = false
  }
}

# Create web messaging deployment
resource "genesyscloud_webdeployments_deployment" "account_balance_deployment" {
  name              = var.deployment_name
  description       = "Web messaging deployment for account balance bot"
  allow_all_domains = true
  allowed_domains   = []
  flow_id           = var.inbound_message_flow_id

  configuration {
    id      = genesyscloud_webdeployments_configuration.account_balance_config.id
    version = genesyscloud_webdeployments_configuration.account_balance_config.version
  }
}
