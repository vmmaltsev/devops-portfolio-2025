variable "project_id" {
  description = "ID проекта GCP."
}

variable "region" {
  description = "Регион для размещения кластера."
}

variable "cluster_name" {
  description = "Имя GKE кластера."
}

variable "network" {
  description = "Имя или self_link VPC сети."
}

variable "subnetwork" {
  description = "Имя или self_link подсети."
}

variable "release_channel" {
  description = "Канал обновлений GKE (RAPID, REGULAR, STABLE)."
  default     = "REGULAR"
  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE"], var.release_channel)
    error_message = "release_channel должен быть RAPID, REGULAR или STABLE."
  }
}

variable "master_ipv4_cidr_block" {
  description = "CIDR блок для master."
}

variable "master_authorized_networks" {
  description = "Список разрешённых сетей для доступа к master."
  type        = list(object({ cidr_block = string, display_name = string }))
  default     = []
}

variable "node_pools" {
  description = "Список node pool-ов и их параметров."
  type = list(object({
    name                = string
    node_count          = number
    machine_type        = string
    preemptible         = bool
    node_oauth_scopes   = list(string)
    node_service_account = string
    node_tags           = list(string)
    node_labels         = map(string)
    node_taints         = list(object({
      key    = string
      value  = string
      effect = string
    }))
    node_disk_type      = string
    node_disk_size_gb   = number
    node_image_type     = string
    enable_gcfs         = bool
    enable_gvnic        = bool
    min_node_count      = number
    max_node_count      = number
  }))
}

variable "node_disk_type" {
  description = "Тип диска для нод."
  default     = "pd-standard"
}

variable "node_disk_size_gb" {
  description = "Размер диска для нод (ГБ)."
  default     = 100
}

variable "node_image_type" {
  description = "Тип образа для нод."
  default     = "COS_CONTAINERD"
}

variable "enable_gcfs" {
  description = "Включить Google Container File System."
  default     = false
}

variable "enable_gvnic" {
  description = "Включить Google Virtual NIC."
  default     = false
} 