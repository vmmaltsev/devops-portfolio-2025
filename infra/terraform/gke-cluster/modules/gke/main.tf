resource "google_container_cluster" "this" {
  name     = var.cluster_name
  location = var.region
  project  = var.project_id
  release_channel {
    channel = var.release_channel
  }
  remove_default_node_pool = true
  initial_node_count       = 1
  network    = var.network
  subnetwork = var.subnetwork
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
  enable_shielded_nodes = true
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  ip_allocation_policy {}
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }
  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.master_authorized_networks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }
  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    network_policy_config {
      disabled = false
    }
  }
  deletion_protection = false
}

resource "google_container_node_pool" "pools" {
  for_each   = { for np in var.node_pools : np.name => np }
  name       = each.value.name
  cluster    = google_container_cluster.this.name
  location   = var.region
  project    = var.project_id
  node_count = each.value.node_count
  node_config {
    machine_type = each.value.machine_type
    preemptible  = each.value.preemptible
    oauth_scopes = each.value.node_oauth_scopes
    service_account = each.value.node_service_account
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
    metadata = {
      disable-legacy-endpoints = "true"
    }
    tags = each.value.node_tags
    labels = each.value.node_labels
    dynamic "taint" {
      for_each = each.value.node_taints
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }
    disk_type    = each.value.node_disk_type
    disk_size_gb = each.value.node_disk_size_gb
    image_type   = each.value.node_image_type
  }
  management {
    auto_upgrade = true
    auto_repair  = true
  }
  autoscaling {
    min_node_count = each.value.min_node_count
    max_node_count = each.value.max_node_count
  }
} 