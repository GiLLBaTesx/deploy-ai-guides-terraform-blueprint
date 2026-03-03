# AI Guide Module Outputs

output "guide_id" {
  value       = genesyscloud_guide.guide.id
  description = "The ID of the created AI Guide"
}

output "guide_name" {
  value       = genesyscloud_guide.guide.name
  description = "The name of the AI Guide"
}

output "guide_version_id" {
  value       = genesyscloud_guide_version.version.id
  description = "The ID of the guide version"
}

output "data_action_id" {
  value       = genesyscloud_integration_action.data_action.id
  description = "The ID of the data action"
}
