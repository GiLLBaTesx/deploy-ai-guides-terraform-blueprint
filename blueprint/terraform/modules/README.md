# Terraform Modules

This directory contains reusable Terraform modules for deploying AI Guides in Genesys Cloud.

## Module Structure

```
modules/
├── ai_guide/          # AI Guide with version and data action
└── bot_flow/          # Bot flow configuration helper
```

## ai_guide Module

Creates an AI Guide with guide version and data action integration.

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

### Usage

```hcl
module "ai_guide" {
  source = "./modules/ai_guide"

  guide_name                   = "Check Account Balance"
  guide_instruction_file       = "account-balance-guide.md"
  input_variable_name          = "account_number"
  input_variable_description   = "Customer's account number"
  output_variable_name         = "current_balance"
  output_variable_description  = "Current account balance"
  data_action_name             = "Get Account Balance"
  data_action_label            = "Get Account Balance"
  data_action_description      = "Retrieves customer account balance"
  integration_id               = var.integration_id
  api_base_url                 = var.api_base_url
}
```

## bot_flow Module

Provides configuration helper for connecting AI Guide to bot flows.

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
| bot_flow_id | The guide ID to use in bot flow configuration |
| connection_instructions | Instructions for connecting guide to bot flow |

### Usage

```hcl
module "bot_flow" {
  source = "./modules/bot_flow"

  guide_id             = module.ai_guide.guide_id
  guide_name           = module.ai_guide.guide_name
  input_variable_name  = "account_number"
  output_variable_name = "current_balance"

  depends_on = [module.ai_guide]
}
```

## Benefits of Modular Architecture

1. **Reusability** - Modules can be used across multiple projects
2. **Maintainability** - Changes are isolated to specific modules
3. **Testability** - Each module can be tested independently
4. **Clean Code** - Main configuration stays simple and readable
5. **Best Practices** - Follows Terraform and Genesys Cloud standards
