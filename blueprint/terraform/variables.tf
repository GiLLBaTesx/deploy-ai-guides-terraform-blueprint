# Variables for Genesys Cloud Terraform configuration
# Note: OAuth credentials are set via environment variables:
# - GENESYSCLOUD_OAUTHCLIENT_ID
# - GENESYSCLOUD_OAUTHCLIENT_SECRET
# - GENESYSCLOUD_REGION

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
