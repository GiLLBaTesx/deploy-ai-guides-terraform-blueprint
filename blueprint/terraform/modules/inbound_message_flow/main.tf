# Inbound Message Flow Module
# Creates an inbound message flow that routes to the bot flow

resource "genesyscloud_flow" "inbound_message" {
  filepath = "${path.module}/inbound-message-flow.yaml"

  substitutions = {
    bot_flow_id   = var.bot_flow_id
    bot_flow_name = var.bot_flow_name
  }
}
