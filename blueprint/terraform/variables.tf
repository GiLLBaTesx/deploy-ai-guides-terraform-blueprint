# Variables for Genesys Cloud Terraform configuration

# Provider credentials
variable "genesyscloud_oauthclient_id" {
  description = "Genesys Cloud OAuth Client ID"
  type        = string
  sensitive   = true
}

variable "genesyscloud_oauthclient_secret" {
  description = "Genesys Cloud OAuth Client Secret"
  type        = string
  sensitive   = true
}

variable "genesyscloud_region" {
  description = "Genesys Cloud region (e.g., us-east-1, eu-west-1, ap-southeast-2)"
  type        = string
}

# Resource configuration variables
variable "integration_id" {
  description = "Integration ID for data actions"
  type        = string
}

variable "api_base_url" {
  description = "Base URL for backend API"
  type        = string
  default     = "https://api.example.com"
}

variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "Genesys Cloud region code (e.g., use1, usw2, euw1)"
  type        = string
  default     = "use1"
}
