output "webservers-alb_hostname" {
  value = module.webservers.alb_hostname
}

output "webservers-rds_cluster_master_endpoint" {
  value = module.webservers.rds_cluster_master_endpoint
}

output "webservers-rds_cluster_reader_endpoint" {
  value = module.webservers.rds_cluster_reader_endpoint
}

output "webservers-anycable_redis_url" {
  value = module.webservers.anycable_redis_url
}

output "tooling-orchestrator-alb_hostname" {
  value = module.tooling_orchestrator.alb_hostname
}
