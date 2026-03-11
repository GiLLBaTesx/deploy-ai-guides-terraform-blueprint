# Terraform configuration for Genesys Cloud AI Guides
# This example demonstrates deploying a complete AI Guide solution using modular architecture

terraform {
  required_providers {
    genesyscloud = {
      source = "mypurecloud/genesyscloud"
    }
  }
}

# Provider configuration using variables
# Variables can be set via:
# - TF_VAR_genesyscloud_oauthclient_id environment variable
# - TF_VAR_genesyscloud_oauthclient_secret environment variable
# - TF_VAR_genesyscloud_region environment variable
# - terraform.tfvars file
# - Command line: -var="genesyscloud_oauthclient_id=..."
provider "genesyscloud" {
  oauthclient_id     = var.genesyscloud_oauthclient_id
  oauthclient_secret = var.genesyscloud_oauthclient_secret
  aws_region         = var.genesyscloud_region
}
