# Inbound Message Flow Module Outputs

output "flow_id" {
  value       = genesyscloud_flow.inbound_message.id
  description = "The ID of the inbound message flow"
}

output "flow_name" {
  value       = genesyscloud_flow.inbound_message.name
  description = "The name of the inbound message flow"
}
