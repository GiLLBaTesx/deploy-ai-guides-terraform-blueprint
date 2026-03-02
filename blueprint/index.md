# Deploy AI Guides using Terraform and CX as Code

> View the full [Deploy AI Guides using Terraform and CX as Code](https://developer.genesys.cloud/blueprints/) article on the Genesys Cloud Developer Center.

This Genesys Cloud Developer Blueprint demonstrates how to deploy AI Guides using Terraform and the Genesys Cloud CX as Code provider. AI Guides enable business users to create AI-powered Virtual Agents using natural language instructions, and this blueprint shows how to manage them as code for version control, automation, and consistent deployments across environments.

![Deployment Workflow](images/deployment-workflow.png "AI Guides Terraform deployment workflow showing the flow from developer through Terraform to Genesys Cloud resources")

## Scenario

An organization wants to deploy AI Guides programmatically to:
* Version control guide instructions alongside infrastructure code
* Deploy guides consistently across dev, test, and production environments
* Automate guide deployments through CI/CD pipelines
* Track changes with full audit history

This blueprint uses the "Check Account Balance" use case - a recommended single-intent guide from AI Guides best practices.

![Use Case Flow](images/use-case-flow.png "Check Account Balance conversational flow showing customer interaction, API call, error handling, and agent transfer")

## Solution

This blueprint demonstrates how to:
* Define AI Guides using Terraform resources (`genesyscloud_guide` and `genesyscloud_guide_version`)
* Store guide instructions in markdown files for version control
* Configure input/output variables for guides
* Create data actions that guides can reference
* Deploy guides across multiple environments using environment variables

## Contents

* [Solution components](#solution-components "Goes to the Solution components section")
* [Prerequisites](#prerequisites "Goes to the Prerequisites section")
* [Implementation steps](#implementation-steps "Goes to the Implementation steps section")
* [Understanding the guide structure](#understanding-the-guide-structure "Goes to the Understanding the guide structure section")
* [Advanced patterns](#advanced-patterns "Goes to the Advanced patterns section")
* [Troubleshooting](#troubleshooting "Goes to the Troubleshooting section")
* [Additional resources](#additional-resources "Goes to the Additional resources section")

## Solution components

* **Genesys Cloud** - A suite of Genesys Cloud services for enterprise-grade communications, collaboration, and contact center management.
* **Genesys Cloud AI Studio** - Platform for building and managing AI capabilities including AI Guides.
* **Terraform** - Infrastructure as code tool for building, changing, and versioning infrastructure safely and efficiently.
* **CX as Code** - Genesys Cloud Terraform provider for managing Genesys Cloud configuration.

## Prerequisites

### Specialized knowledge

* Administrator-level knowledge of Genesys Cloud
* Experience with Terraform and infrastructure as code concepts
* Familiarity with AI Guides and Virtual Agents

### Genesys Cloud account

* A Genesys Cloud license. For more information, see [Genesys Cloud Pricing](https://www.genesys.com/pricing "Opens the Genesys Cloud pricing page").
* Genesys Cloud AI Experience license
* Virtual Agent enabled in your organization
* AI Studio permissions
* Master Admin role or equivalent permissions

### Development tools

* Terraform (v1.0 or later)
* Git

## Implementation steps

### Clone the repository

Clone the [deploy-ai-guides-terraform-blueprint](https://github.com/GiLLBaTesx/deploy-ai-guides-terraform-blueprint) repository from GitHub:

```bash
git clone https://github.com/GiLLBaTesx/deploy-ai-guides-terraform-blueprint.git
cd deploy-ai-guides-terraform-blueprint
```

### Set up Genesys Cloud OAuth credentials

1. Navigate to **Admin > Integrations > OAuth** in Genesys Cloud
2. Click **Add Client**
3. Configure the OAuth client:
   * **App Name**: Terraform AI Guides
   * **Grant Type**: Client Credentials
   * **Roles**: Assign the following roles:
     - `knowledge:guide:add`
     - `knowledge:guide:edit`
     - `knowledge:guide:view`
     - `integrations:integration:view`
     - `integrations:action:add`
     - `integrations:action:edit`
4. Click **Save** and note the Client ID and Client Secret

### Get Integration ID

1. Navigate to **Admin > Integrations > Integrations**
2. Find or create a Web Services Data Actions integration
3. Click on the integration and copy its ID from the URL

### Configure environment variables

1. Navigate to the terraform directory:
```bash
cd blueprint/terraform
```

2. Copy the example environment file:
```bash
cp .env.example .env
```

3. Edit `.env` and add your credentials:
```bash
# Genesys Cloud Provider Environment Variables
GENESYSCLOUD_OAUTHCLIENT_ID=your-client-id
GENESYSCLOUD_OAUTHCLIENT_SECRET=your-client-secret
GENESYSCLOUD_REGION=your-region-here  # e.g., us-east-1, eu-west-1, ap-southeast-2

# Terraform Variables for Resources
TF_VAR_integration_id=your-integration-id
TF_VAR_api_base_url=https://api.example.com
TF_VAR_environment=dev
```

4. Load the environment variables:
```bash
source .env
```

### Initialize and deploy with Terraform

1. Initialize Terraform:
```bash
terraform init
```

2. Review the deployment plan:
```bash
terraform plan
```

The plan will show 3 resources to be created:
- AI Guide container
- Guide version with instructions and variables
- Data action for account balance retrieval

3. Apply the configuration:
```bash
terraform apply
```

4. Type `yes` when prompted to confirm the deployment

5. Note the output values:
```
Outputs:

data_action_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
guide_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
guide_name = "Check Account Balance"
guide_version_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

### Verify the deployment

1. Log into Genesys Cloud
2. Navigate to **Admin > AI Studio > Guides**
3. Verify that "Check Account Balance" guide appears in the list
4. Click on the guide to review:
   * Guide instructions from the markdown file
   * Input variable: `account_number`
   * Output variable: `current_balance`
   * Data action reference: "Get Account Balance"

### Connect the guide to a bot flow

1. In Architect, create or edit a bot flow
2. Add a **Call Guide** action
3. Select "Check Account Balance" guide
4. Map bot flow variables:
   * Input: Map customer account number to `account_number`
   * Output: Map `current_balance` to a flow variable
5. Publish the bot flow
6. Test the bot flow to verify the guide executes correctly

## Understanding the guide structure

AI Guides in Terraform use a two-resource model for versioning:

### Guide Container (`genesyscloud_guide`)

The guide resource creates a container with just a name:

```hcl
resource "genesyscloud_guide" "account_balance_guide" {
  name = "Check Account Balance"
}
```

This container holds all versions of your guide, enabling version management and rollback capabilities.

### Guide Version (`genesyscloud_guide_version`)

The guide version contains all the logic and is where you define:

**Instructions**: Natural language steps that define your guide's behavior
- Use markdown formatting for readability
- Use headings (`##`) to define steps
- Reference variables with `$variable_name` syntax
- Reference data actions with `/data_action_label/` syntax
- Use commands like: Say, Ask, Call, Store, Go To, If/Then/Else, Exit

**Variables**: Define input, output, and internal variables

```hcl
variables {
  name        = "account_number"
  type        = "String"
  scope       = "Input"
  description = "Customer's account number"
}
```

Variable scopes:
- `Input` - Receives value from Architect flow
- `Output` - Returns value to Architect flow
- `InputAndOutput` - Both input and output
- `Internal` - Used only within the guide

**Data Actions**: Reference existing data actions

```hcl
resources {
  data_action {
    data_action_id = genesyscloud_integration_action.get_account_balance.id
    label          = "Get Account Balance"
    description    = "Retrieves customer account balance"
  }
}
```

The `label` is how you reference the data action in your instructions using `/label/` syntax.

## Advanced patterns

### Versioning guides

The two-resource model enables proper versioning:

```hcl
resource "genesyscloud_guide" "support_guide" {
  name = "Customer Support Guide"
}

# Version 1.0
resource "genesyscloud_guide_version" "support_v1" {
  guide_id    = genesyscloud_guide.support_guide.id
  instruction = file("${path.module}/guides/support-v1.md")
  # ... variables and resources
}

# Version 2.0 with improvements
resource "genesyscloud_guide_version" "support_v2" {
  guide_id    = genesyscloud_guide.support_guide.id
  instruction = file("${path.module}/guides/support-v2.md")
  # ... updated variables and resources
}
```

### Multi-environment deployment

Use Terraform workspaces or variables to manage guides across environments:

```hcl
resource "genesyscloud_guide" "support_guide" {
  name = "Customer Support - ${var.environment}"
}

resource "genesyscloud_guide_version" "support_v1" {
  guide_id    = genesyscloud_guide.support_guide.id
  instruction = templatefile("${path.module}/guides/support-guide.md", {
    environment  = var.environment
    api_endpoint = var.api_endpoints[var.environment]
  })
  # ... variables and resources
}
```

### Modular guide design

Keep your guide instructions in separate markdown files for better maintainability:

```hcl
resource "genesyscloud_guide_version" "account_balance_v1" {
  guide_id    = genesyscloud_guide.account_balance_guide.id
  instruction = file("${path.module}/guides/account-balance-guide.md")
  
  # Variables and resources...
}
```

This approach provides:
- Better version control with meaningful diffs
- Easier collaboration with business users
- Cleaner Terraform code

### CI/CD integration

Integrate with your CI/CD pipeline for automated deployments:

```yaml
# .github/workflows/deploy-guides.yml
name: Deploy AI Guides

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: hashicorp/setup-terraform@v1
      
      - name: Terraform Init
        run: terraform init
        working-directory: blueprint/terraform
        
      - name: Terraform Apply
        run: terraform apply -auto-approve
        working-directory: blueprint/terraform
        env:
          GENESYSCLOUD_OAUTHCLIENT_ID: ${{ secrets.GENESYS_CLIENT_ID }}
          GENESYSCLOUD_OAUTHCLIENT_SECRET: ${{ secrets.GENESYS_CLIENT_SECRET }}
          GENESYSCLOUD_REGION: ${{ secrets.GENESYS_REGION }}
```

## Troubleshooting

### Guide not appearing in AI Studio

**Problem**: After running `terraform apply`, the guide doesn't appear in AI Studio.

**Solutions**:
- Verify AI Studio permissions are granted to your OAuth client
- Check that Virtual Agent is enabled in your organization
- Ensure you're using the latest version of the Terraform provider
- Confirm the guide was created: `terraform state show genesyscloud_guide.account_balance_guide`

### "Resource Not Found" error

**Problem**: Terraform returns a 404 error when trying to create or read a guide.

**Solutions**:
- Confirm AI Guides feature is available in your Genesys Cloud region
- Verify your OAuth client has all required permissions
- Check that `guide_id` references are correct in guide version resources
- Ensure the Terraform provider version supports AI Guides resources

### Variables not working in guide

**Problem**: Variables aren't being populated or passed correctly during guide execution.

**Solutions**:
- Ensure variable names in instructions match the variable definitions exactly (case-sensitive)
- Check that variable scope is appropriate:
  - Use `Input` for values from Architect flow
  - Use `Output` for values returned to Architect flow
  - Use `Internal` for values used only within the guide
- Verify variable types match the data being stored (String, Number, Boolean, Object)
- Use `$variable_name` syntax in instructions

### Data action not found

**Problem**: Guide can't find or execute the referenced data action.

**Solutions**:
- Verify the data action exists and is published
- Check that `data_action_id` matches the actual data action resource ID
- Ensure the `label` in the resource block matches how you reference it in instructions (use `/label/` syntax)
- Confirm the data action's integration is active and configured correctly

### Permission denied errors

**Problem**: OAuth client lacks permissions to create or modify guides.

**Solutions**:
- Review the complete permissions list in the Prerequisites section
- Ensure OAuth client has been granted all necessary permissions:
  - `knowledge:guide:add`
  - `knowledge:guide:edit`
  - `knowledge:guide:view`
  - `integrations:integration:view`
  - `integrations:action:add`
  - `integrations:action:edit`
- Verify the OAuth client role has AI Studio permissions enabled

### Terraform state issues

**Problem**: Terraform shows resources as changed when nothing has changed.

**Solutions**:
- This can happen with instruction formatting. Use `file()` function to load instructions from external files
- Avoid inline heredoc (`<<-EOT`) for large instructions as whitespace can cause drift
- Use `terraform refresh` to sync state with actual resources
- Consider using `lifecycle { ignore_changes = [instruction] }` if instructions are managed outside Terraform

## Additional resources

* [AI Guides Overview](https://help.mypurecloud.com/articles/ai-guides-overview/)
* [CX as Code Documentation](https://developer.genesys.cloud/devapps/cx-as-code/)
* [Genesys Cloud Terraform Provider](https://registry.terraform.io/providers/MyPureCloud/genesyscloud/latest/docs)
* [Genesys Cloud Terraform Provider - Guide Resource](https://registry.terraform.io/providers/MyPureCloud/genesyscloud/latest/docs/resources/guide)
* [Genesys Cloud Terraform Provider - Guide Version Resource](https://registry.terraform.io/providers/MyPureCloud/genesyscloud/latest/docs/resources/guide_version)
* [Terraform Documentation](https://www.terraform.io/docs)
