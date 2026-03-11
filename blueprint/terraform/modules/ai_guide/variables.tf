# AI Guide Module Variables

variable "guide_name" {
  description = "Name of the AI Guide"
  type        = string
}

variable "guide_instruction_file" {
  description = "Path to the guide instruction markdown file"
  type        = string
}

variable "input_variable_name" {
  description = "Name of the input variable"
  type        = string
}

variable "input_variable_description" {
  description = "Description of the input variable"
  type        = string
}

variable "output_variable_name" {
  description = "Name of the output variable"
  type        = string
}

variable "output_variable_description" {
  description = "Description of the output variable"
  type        = string
}

variable "data_action_name" {
  description = "Name of the data action"
  type        = string
}

variable "data_action_label" {
  description = "Label for referencing the data action in guide instructions"
  type        = string
}

variable "data_action_description" {
  description = "Description of the data action"
  type        = string
}

variable "data_action_category" {
  description = "Category of the data action"
  type        = string
  default     = "Account Management"
}

variable "integration_id" {
  description = "Integration ID for data actions"
  type        = string
}

variable "api_base_url" {
  description = "Base URL for backend API"
  type        = string
}
