# Bot Flow Module Variables

variable "guide_id" {
  description = "ID of the AI Guide to call"
  type        = string
}

variable "guide_name" {
  description = "Name of the AI Guide"
  type        = string
}

variable "input_variable_name" {
  description = "Name of the input variable to pass to the guide"
  type        = string
}

variable "output_variable_name" {
  description = "Name of the output variable from the guide"
  type        = string
}
