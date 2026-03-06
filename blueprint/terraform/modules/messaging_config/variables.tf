# Messaging Configuration Module Variables

variable "config_name" {
  description = "Name of the web messaging configuration"
  type        = string
  default     = "Account Balance Web Messaging"
}

variable "deployment_name" {
  description = "Name of the web messaging deployment"
  type        = string
  default     = "Account Balance Deployment"
}

variable "inbound_message_flow_id" {
  description = "ID of the inbound message flow to use"
  type        = string
}

variable "region" {
  description = "Genesys Cloud region"
  type        = string
  default     = "use1"
}
