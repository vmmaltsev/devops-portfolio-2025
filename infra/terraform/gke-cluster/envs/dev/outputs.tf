output "kubeconfig_command" {
  description = "Команда для получения kubeconfig кластера"
  value       = module.gke.kubeconfig_command
}

output "cluster_name" {
  description = "Имя GKE кластера"
  value       = module.gke.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint кластера Kubernetes"
  value       = module.gke.endpoint
} 