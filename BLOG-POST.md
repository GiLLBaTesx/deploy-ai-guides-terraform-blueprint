# Provisioning AI Guides in Genesys Cloud with Terraform

## Introduction

AI Guides in Genesys Cloud enable business users to create AI-powered virtual agents using natural language instructions. While the Genesys Cloud UI provides an intuitive interface for creating guides, managing them as code through Terraform offers significant advantages: version control, automated deployments, consistency across environments, and integration with CI/CD pipelines.

This article explores how to provision AI Guide objects in Genesys Cloud using Terraform, covering the required resources, complex schemas, best practices, and the complete deployment workflow.

## Understanding AI Guides Architecture

Before diving into Terraform, it's important to understand how AI Guides are structured in Genesys Cloud:

- **Guide Container**: A top-level object that holds all versions of a guide
- **Guide Version**: Contains the actual logic, instructions, variables, and resource references
- **Data Actions**: External API integrations that guides can call
- **Variables**: Input, output, and internal variables for data flow

This architecture enables versioning and rollback capabilities, similar to how applications are versioned in production environments.

## Terraform Resources Required

To provision a complete AI Guide in Genesys Cloud, you need three primary Terraform resources:

### 1. Guide Container (`genesyscloud_guide`)

The guide container is the simplest resource - it only requires a name:

```hcl
resource "genesyscloud_guide" "account_balance_guide" {
  name = "Check Account Balance"
}
```

This creates a container that will hold all versions of your guide. The container's ID is used to link guide versions to it.

### 2. Guide Version (`genesyscloud_guide_version`)

The guide version is where the complexity lies. This resource contains:

```hcl
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
```

### 3. Data Action (`genesyscloud_integration_action`)

Data actions enable guides to call external APIs:

```hcl
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
    request_url_template = "${var.api_base_url}/accounts/${input.accountNumber}/balance"
    request_type         = "GET"
    request_template     = "${input.rawRequest}"
  }

  config_response {
    translation_map = {
      balance     = "$.balance.amount"
      currency    = "$.balance.currency"
      lastUpdated = "$.lastUpdated"
    }
    success_template = "${rawResult}"
  }
}
```

## Complex Schemas and Required Fields

### Guide Version Schema Complexity

The `genesyscloud_guide_version` resource has several complex nested blocks:

#### Variables Block

Each variable requires:
- **name** (required): Variable identifier used in instructions
- **type** (required): String, Number, Boolean, or Object
- **scope** (required): Input, Output, InputAndOutput, or Internal
- **description** (optional but recommended): Explains the variable's purpose

Variable scopes determine data flow:
- `Input`: Receives values from Architect bot flow
- `Output`: Returns values to Architect bot flow
- `InputAndOutput`: Both input and output
- `Internal`: Used only within the guide

#### Resources Block

The resources block references data actions:
- **data_action_id** (required): ID of the data action resource
- **label** (required): How you reference the action in instructions (use `/label/` syntax)
- **description** (optional): Explains what the action does

#### Instructions Field

The `instruction` field contains natural language steps that define the guide's behavior. Key considerations:

- Use markdown formatting for readability
- Reference variables with `$variable_name` syntax
- Reference data actions with `/data_action_label/` syntax
- Use headings (`##`) to define steps
- Include error handling logic

**Best Practice**: Store instructions in separate markdown files and use the `file()` function:

```hcl
instruction = file("${path.module}/guides/account-balance-guide.md")
```

This approach provides:
- Better version control with meaningful diffs
- Easier collaboration with business users
- Cleaner Terraform code
- Avoids whitespace drift issues

### Data Action Schema Complexity

Data actions use JSON Schema for input/output contracts:

#### Contract Input

Defines what data the action expects:

```hcl
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
```

#### Contract Output

Defines what data the action returns:

```hcl
contract_output = jsonencode({
  type = "object"
  properties = {
    balance = {
      type        = "string"
      description = "Current account balance"
    }
    currency = {
      type        = "string"
      description = "Currency code"
    }
  }
})
```

#### Request Configuration

The `config_request` block defines how to call the API:

- **request_url_template**: API endpoint with variable interpolation
- **request_type**: HTTP method (GET, POST, PUT, DELETE)
- **request_template**: Request body template (for POST/PUT)

#### Response Configuration

The `config_response` block maps API responses to output variables:

- **translation_map**: JSONPath expressions to extract data
- **success_template**: Template for successful responses

**JSONPath Examples**:
- `$.balance.amount` - Extracts nested value
- `$.items[0].name` - Extracts first array element
- `$.data.*` - Extracts all properties

## Best Practices

### 1. Use Environment Variables for Credentials

Never hardcode credentials in Terraform files. Use environment variables:

```bash
export GENESYSCLOUD_OAUTHCLIENT_ID="your-client-id"
export GENESYSCLOUD_OAUTHCLIENT_SECRET="your-client-secret"
export GENESYSCLOUD_REGION="us-east-1"
```

The Genesys Cloud provider automatically reads these variables.

### 2. Separate Guide Instructions from Terraform Code

Store guide instructions in separate markdown files:

```
terraform/
├── guides/
│   ├── account-balance-guide.md
│   └── order-status-guide.md
├── main.tf
└── variables.tf
```

This separation enables:
- Business users to edit instructions without touching infrastructure code
- Better version control with meaningful diffs
- Easier code reviews

### 3. Use the Two-Resource Model for Versioning

Always create separate guide container and version resources:

```hcl
# Container
resource "genesyscloud_guide" "support_guide" {
  name = "Customer Support Guide"
}

# Version 1.0
resource "genesyscloud_guide_version" "support_v1" {
  guide_id    = genesyscloud_guide.support_guide.id
  instruction = file("${path.module}/guides/support-v1.md")
  # ... variables and resources
}

# Version 2.0 (when needed)
resource "genesyscloud_guide_version" "support_v2" {
  guide_id    = genesyscloud_guide.support_guide.id
  instruction = file("${path.module}/guides/support-v2.md")
  # ... updated variables and resources
}
```

This enables version management and rollback capabilities.

### 4. Follow Single-Intent Guide Pattern

Each guide should focus on one specific task:
- ✅ Good: "Check Account Balance"
- ✅ Good: "Update Shipping Address"
- ❌ Bad: "Account Management" (too broad)

Single-intent guides are:
- Easier to maintain
- More reusable
- Better for testing
- Clearer for users

### 5. Implement Comprehensive Error Handling

Always include error handling in guide instructions:

```markdown
## Error Handling

If the data action fails:

"I'm sorry, but I couldn't retrieve your account information. Please try again, or I can transfer you to a customer service representative."

Ask if they want to:
- Try again (return to Step 1)
- Speak with a representative (transfer to human agent)
```

### 6. Use Descriptive Variable Names

Variable names should be clear and self-documenting:
- ✅ Good: `account_number`, `current_balance`, `customer_email`
- ❌ Bad: `var1`, `data`, `temp`

### 7. Add Outputs for Important Resources

Define outputs to easily reference created resources:

```hcl
output "guide_id" {
  value       = genesyscloud_guide.account_balance_guide.id
  description = "The ID of the created AI Guide"
}

output "guide_version_id" {
  value       = genesyscloud_guide_version.account_balance_v1.id
  description = "The ID of the guide version"
}
```

### 8. Use Variables for Environment-Specific Values

Make your Terraform reusable across environments:

```hcl
variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
  default     = "dev"
}

resource "genesyscloud_guide" "support_guide" {
  name = "Customer Support - ${var.environment}"
}
```

### 9. Validate Data Action Contracts

Ensure your JSON schemas are valid and complete:
- Include all required fields
- Use appropriate data types
- Add descriptions for documentation
- Test with actual API responses

### 10. Document OAuth Permissions

Clearly document required OAuth permissions:

```hcl
# Required OAuth permissions:
# - knowledge:guide:add
# - knowledge:guide:edit
# - knowledge:guide:view
# - integrations:integration:view
# - integrations:action:add
# - integrations:action:edit
```

## Running Terraform: Complete Workflow

### Step 1: Set Up Environment Variables

Create a `.env` file (never commit this):

```bash
# Genesys Cloud Provider Environment Variables
export GENESYSCLOUD_OAUTHCLIENT_ID="your-client-id"
export GENESYSCLOUD_OAUTHCLIENT_SECRET="your-client-secret"
export GENESYSCLOUD_REGION="us-east-1"

# Terraform Variables for Resources
export TF_VAR_integration_id="your-integration-id"
export TF_VAR_api_base_url="https://api.example.com"
export TF_VAR_environment="dev"
```

Load the variables:

```bash
source .env
```

### Step 2: Initialize Terraform

Initialize the working directory and download the Genesys Cloud provider:

```bash
terraform init
```

**What happens**:
- Downloads the `genesyscloud` provider
- Initializes the backend (local by default)
- Creates `.terraform` directory
- Creates `.terraform.lock.hcl` file

**Expected output**:
```
Initializing the backend...
Initializing provider plugins...
- Finding latest version of mypurecloud/genesyscloud...
- Installing mypurecloud/genesyscloud v1.x.x...

Terraform has been successfully initialized!
```

### Step 3: Validate Configuration

Check for syntax errors:

```bash
terraform validate
```

**Expected output**:
```
Success! The configuration is valid.
```

### Step 4: Format Code

Ensure consistent formatting:

```bash
terraform fmt
```

This automatically formats all `.tf` files according to Terraform conventions.

### Step 5: Plan the Deployment

Preview what Terraform will create:

```bash
terraform plan
```

**What to review**:
- Number of resources to be created (should be 3 for this example)
- Resource names and properties
- Any warnings or errors

**Expected output**:
```
Terraform will perform the following actions:

  # genesyscloud_guide.account_balance_guide will be created
  + resource "genesyscloud_guide" "account_balance_guide" {
      + id   = (known after apply)
      + name = "Check Account Balance"
    }

  # genesyscloud_guide_version.account_balance_v1 will be created
  + resource "genesyscloud_guide_version" "account_balance_v1" {
      + guide_id    = (known after apply)
      + id          = (known after apply)
      + instruction = (file content)
      ...
    }

  # genesyscloud_integration_action.get_account_balance will be created
  + resource "genesyscloud_integration_action" "get_account_balance" {
      + id             = (known after apply)
      + name           = "Get Account Balance"
      + integration_id = "your-integration-id"
      ...
    }

Plan: 3 to add, 0 to change, 0 to destroy.
```

### Step 6: Apply the Configuration

Deploy the resources:

```bash
terraform apply
```

Terraform will show the plan again and ask for confirmation. Type `yes` to proceed.

**Expected output**:
```
genesyscloud_guide.account_balance_guide: Creating...
genesyscloud_guide.account_balance_guide: Creation complete after 2s [id=abc123...]
genesyscloud_integration_action.get_account_balance: Creating...
genesyscloud_integration_action.get_account_balance: Creation complete after 3s [id=def456...]
genesyscloud_guide_version.account_balance_v1: Creating...
genesyscloud_guide_version.account_balance_v1: Creation complete after 4s [id=ghi789...]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

data_action_id = "def456..."
guide_id = "abc123..."
guide_name = "Check Account Balance"
guide_version_id = "ghi789..."
```

### Step 7: Verify the Deployment

Check the Terraform state:

```bash
terraform show
```

Or query specific resources:

```bash
terraform state show genesyscloud_guide.account_balance_guide
```

### Step 8: Verify in Genesys Cloud

1. Log into Genesys Cloud
2. Navigate to **Admin > AI Studio > Guides**
3. Verify "Check Account Balance" appears
4. Click on the guide to review instructions and variables

### Making Changes

When you need to update the guide:

1. Modify the guide instructions file or Terraform configuration
2. Run `terraform plan` to preview changes
3. Run `terraform apply` to apply changes

Terraform will show what will be modified:
```
Plan: 0 to add, 1 to change, 0 to destroy.
```

### Destroying Resources

To remove all resources (use with caution):

```bash
terraform destroy
```

This is useful for:
- Cleaning up test environments
- Removing deprecated guides
- Starting fresh

## Common Issues and Solutions

### Issue: "Resource Not Found" Error

**Problem**: Terraform returns a 404 error when creating a guide.

**Solution**:
- Verify AI Guides feature is available in your region
- Check OAuth client has all required permissions
- Ensure you're using a compatible Terraform provider version

### Issue: Variables Not Working in Guide

**Problem**: Variables aren't populated during guide execution.

**Solution**:
- Ensure variable names in instructions match definitions exactly (case-sensitive)
- Use correct syntax: `$variable_name` in instructions
- Verify variable scope matches usage (Input/Output/Internal)

### Issue: Data Action Not Found

**Problem**: Guide can't find the referenced data action.

**Solution**:
- Verify `data_action_id` is correct
- Ensure `label` matches how you reference it in instructions (use `/label/` syntax)
- Check that the data action's integration is active

### Issue: Terraform State Drift

**Problem**: Terraform shows changes when nothing has changed.

**Solution**:
- Use `file()` function for instructions instead of inline heredoc
- Avoid manual changes in Genesys Cloud UI
- Run `terraform refresh` to sync state

## Conclusion

Provisioning AI Guides with Terraform brings infrastructure-as-code benefits to conversational AI development. By understanding the required resources, complex schemas, and best practices, you can create maintainable, version-controlled AI Guides that deploy consistently across environments.

Key takeaways:
- Use the two-resource model (guide + version) for proper versioning
- Store guide instructions in separate markdown files
- Implement comprehensive error handling
- Follow single-intent guide pattern
- Use environment variables for credentials
- Leverage Terraform's plan/apply workflow for safe deployments

The complete example code is available at: https://github.com/GiLLBaTesx/deploy-ai-guides-terraform-blueprint

## Additional Resources

- [AI Guides Overview](https://help.mypurecloud.com/articles/ai-guides-overview/)
- [Genesys Cloud Terraform Provider Documentation](https://registry.terraform.io/providers/MyPureCloud/genesyscloud/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [CX as Code Documentation](https://developer.genesys.cloud/devapps/cx-as-code/)
