resource "google_compute_network" "vpc" {
  name                    = "${var.environment}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  project                 = var.project_id
}

resource "google_compute_subnetwork" "subnet" {
  for_each      = { for s in var.subnetworks : s.name => s }
  name          = each.value.name
  ip_cidr_range = each.value.ip_cidr_range
  region        = each.value.region
  network       = google_compute_network.vpc.id
  project       = var.project_id

  private_ip_google_access = each.value.private_ip_google_access
  stack_type               = each.value.stack_type

  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }
}

resource "google_compute_router" "nat_router" {
  name    = "${var.environment}-router"
  region  = var.subnetworks[0].region
  network = google_compute_network.vpc.id
  project = var.project_id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.environment}-nat"
  router                             = google_compute_router.nat_router.name
  region                             = var.subnetworks[0].region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  project                            = var.project_id

  log_config {
    enable = true
    filter = var.nat_log_filter
  }
}
