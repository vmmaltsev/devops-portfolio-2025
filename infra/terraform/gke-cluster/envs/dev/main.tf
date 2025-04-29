resource "google_service_account" "gke_nodes" {
  account_id   = "dev-gke-nodes"
  display_name = "GKE nodes service account"
  project      = var.project_id
}

resource "google_project_iam_member" "gke_nodes_container_node_sa" {
  project = var.project_id
  role    = "roles/container.nodeServiceAccount"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "gke_nodes_artifact_registry_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "gke_nodes_instance_admin" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "gke_nodes_sa_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

module "network" {
  source         = "../../modules/network"
  project_id     = var.project_id
  environment    = var.environment
  nat_log_filter = "ERRORS_ONLY"
  subnetworks = [
    {
      name                     = "dev-subnet"
      region                   = var.region
      ip_cidr_range            = "10.10.0.0/16"
      private_ip_google_access = true
      stack_type               = "IPV4_ONLY"
      secondary_ranges = [
        { range_name = "pods", ip_cidr_range = "10.16.0.0/14" },
        { range_name = "services", ip_cidr_range = "10.20.0.0/20" }
      ]
    }
  ]
}

module "gke" {
  source                 = "../../modules/gke"
  project_id             = var.project_id
  region                 = "${var.region}-a"
  cluster_name           = "dev-gke"
  network                = module.network.network_self_link
  subnetwork             = module.network.subnet_self_links[0]
  release_channel        = "REGULAR"
  master_ipv4_cidr_block = "172.16.0.0/28"
  master_authorized_networks = [
    { cidr_block = "0.0.0.0/0", display_name = "all" }
  ]
  node_pools = [
    {
      name                 = "dev-pool"
      node_count           = 1
      machine_type         = "e2-medium"
      preemptible          = false
      node_oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
      node_service_account = google_service_account.gke_nodes.email
      node_tags            = ["dev", "gke"]
      node_labels          = { env = "dev" }
      node_taints          = []
      node_disk_type       = "pd-standard"
      node_disk_size_gb    = 30
      node_image_type      = "COS_CONTAINERD"
      enable_gcfs          = false
      enable_gvnic         = false
      min_node_count       = 1
      max_node_count       = 1
    }
  ]
} 