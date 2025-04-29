output "cluster_name" {
  value = google_container_cluster.this.name
}

output "cluster_id" {
  value = google_container_cluster.this.id
}

output "endpoint" {
  value = google_container_cluster.this.endpoint
}

output "ca_certificate" {
  value = google_container_cluster.this.master_auth[0].cluster_ca_certificate
}

output "node_pool_names" {
  value = [for np in google_container_node_pool.pools : np.name]
}

output "node_pool_ids" {
  value = [for np in google_container_node_pool.pools : np.id]
}

output "kubeconfig_command" {
  description = "Команда для получения kubeconfig кластера"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.this.name} --region ${google_container_cluster.this.location} --project ${google_container_cluster.this.project}"
} 