# Terraform Modules

This directory contains reusable Terraform modules for deploying a complete AI Guide solution in Genesys Cloud.

## Module Structure

```
modules/
├── ai_guide/              # AI Guide with version and data action
├── bot_flow/              # Bot flow that calls the AI Guide
├── inbound_message_flow/  # Inbound message flow routing
└── messaging_config/      # Web messaging configuration and deployment
```

## ai_guide Module

Creates an AI Guide with guide version and data action integration.

### Resources
- `genesyscloud_guide` - AI Guide container
- `genesyscloud_guide_version` - Guide version with instructions
- `genesyscloud_integration_action` - Data action for API calls

### Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| guide_name | Name of the AI Guide | string | yes |
| guide_instruction_file | Path to guide instruction markdown file | string | yes |
| input_variable_name | Name of the input variable | string | yes |
| input_variable_description | Description of the input variable | string | yes |
| output_variable_name | Name of the output variable | string | yes |
| output_variable_description | Description of the output variable | string | yes |
| data_action_name | Name of the data action | string | yes |
| data_action_label | Label for referencing data action in guide | string | yes |
| data_action_description | Description of the data action | string | yes |
| integration_id | Integration ID for data actions | string | yes |
| api_base_url | Base URL for backend API | string | yes |

### Outputs

| Name | Description |
|------|-------------|
| guide_id | The ID of the created AI Guide |
| guide_name | The name of the AI Guide |
| guide_version_id | The ID of the guide version |
| data_action_id | The ID of the data action |

## bot_flow Module

Creates a bot flow that calls the AI Guide.

### Resources
- `genesyscloud_flow` - Bot flow with guide integration

### Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| guide_id | ID of the AI Guide to call | string | yes |
| guide_name | Name of the AI Guide | string | yes |
| input_variable_name | Name of the input variable | string | yes |
| output_variable_name | Name of the output variable | string | yes |

### Outputs

| Name | Description |
|------|-------------|
| bot_flow_id | The ID of the bot flow |
| bot_flow_name | The name of the bot flow |
| connection_instructions | Instructions for next steps |

## inbound_message_flow Module

Creates an inbound message flow that routes to the bot flow.

### Resources
- `genesyscloud_flow` - Inbound message flow

### Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| bot_flow_id | ID of the bot flow to route to | string | yes |
| bot_flow_name | Name of the bot flow | string | yes |

### Outputs

| Name | Description |
|------|-------------|
| flow_id | The ID of the inbound message flow |
| flow_name | The name of the flow |

## messaging_config Module

Creates web messaging configuration and deployment.

### Resources
- `genesyscloud_webdeployments_configuration` - Web messaging config
- `genesyscloud_webdeployments_deployment` - Web messaging deployment

### Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| config_name | Name of the messaging configuration | string | no (default provided) |
| deployment_name | Name of the deployment | string | no (default provided) |
| inbound_message_flow_id | ID of the inbound message flow | string | yes |
| region | Genesys Cloud region code | string | no (default: use1) |

### Outputs

| Name | Description |
|------|-------------|
| configuration_id | The ID of the configuration |
| deployment_id | The ID of the deployment |
| deployment_snippet | JavaScript snippet for website |
| deployment_url | URL to view in admin console |

## Complete Solution Flow

```
ai_guide
  ↓ (guide_id)
bot_flow
  ↓ (bot_flow_id)
inbound_message_flow
  ↓ (flow_id)
messaging_config
  ↓ (deployment_snippet)
Website Integration
```

## Usage Example

```hcl
# AI Guide
module "ai_guide" {
  source = "./modules/ai_guide"
  guide_name = "Check Account Balance"
  # ... other inputs
}

# Bot Flow
module "bot_flow" {
  source = "./modules/bot_flow"
  guide_id = module.ai_guide.guide_id
  guide_name = module.ai_guide.guide_name
  # ... other inputs
  depends_on = [module.ai_guide]
}

# Inbound Message Flow
module "inbound_message_flow" {
  source = "./modules/inbound_message_flow"
  bot_flow_id = module.bot_flow.bot_flow_id
  bot_flow_name = module.bot_flow.bot_flow_name
  depends_on = [module.bot_flow]
}

# Messaging Configuration
module "messaging_config" {
  source = "./modules/messaging_config"
  inbound_message_flow_id = module.inbound_message_flow.flow_id
  region = var.region
  depends_on = [module.inbound_message_flow]
}
```

## Benefits of Modular Architecture

1. **Reusability** - Modules can be used across multiple projects
2. **Maintainability** - Changes are isolated to specific modules
3. **Testability** - Each module can be tested independently
4. **Clean Code** - Main configuration stays simple and readable
5. **Complete Solution** - End-to-end deployment from AI Guide to web messaging
6. **Best Practices** - Follows Terraform and Genesys Cloud standards

