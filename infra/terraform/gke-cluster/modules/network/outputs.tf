output "network"     { value = google_compute_network.vpc.name }
output "network_id"  { value = google_compute_network.vpc.id }
output "network_self_link" { value = google_compute_network.vpc.self_link }

output "subnet_names" {
  value = [for s in google_compute_subnetwork.subnet : s.name]
}
output "subnet_ids" {
  value = [for s in google_compute_subnetwork.subnet : s.id]
}
output "subnet_self_links" {
  value = [for s in google_compute_subnetwork.subnet : s.self_link]
}
