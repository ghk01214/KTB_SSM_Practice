output "endpoint" {
  description = "Endpoint of the load balancer"
  value       = module.load_balancer.endpoint
}

output "node_id" {
  description = "ID of the sample node"
  value       = module.node.node_id
}