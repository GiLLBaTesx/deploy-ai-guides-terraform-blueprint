# Bot Flow Module
# Note: This module provides the bot flow configuration
# The actual bot flow should be created in Architect UI and connected to the AI Guide

# This is a placeholder for bot flow configuration
# In a real implementation, you would use genesyscloud_flow resource
# or deploy the flow using Archy CLI

# For now, we'll output the guide information needed to connect in Architect
locals {
  bot_flow_instructions = <<-EOT
    To connect this AI Guide to a bot flow:
    
    1. In Architect, create or edit a bot flow
    2. Add a "Call Guide" action
    3. Select guide: ${var.guide_name}
    4. Map input variable: ${var.input_variable_name}
    5. Map output variable: ${var.output_variable_name}
    6. Publish the bot flow
    
    Guide ID: ${var.guide_id}
  EOT
}
