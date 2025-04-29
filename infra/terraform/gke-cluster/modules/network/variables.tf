variable "project_id" {
  description = "ID проекта GCP, в котором будут создаваться ресурсы."
}

variable "environment" {
  description = "Имя окружения (например, dev, prod)."
}

variable "subnetworks" {
  description = "Список подсетей и их параметров."
  type = list(object({
    name                      = string
    region                    = string
    ip_cidr_range             = string
    private_ip_google_access  = bool
    stack_type                = string
    secondary_ranges = list(object({
      range_name    = string
      ip_cidr_range = string
    }))
  }))
}

variable "nat_log_filter" {
  description = "Уровень логирования NAT (например, ERRORS_ONLY, TRANSLATIONS_ONLY, ALL)."
  default     = "ERRORS_ONLY"
  validation {
    condition     = contains(["ERRORS_ONLY", "TRANSLATIONS_ONLY", "ALL"], var.nat_log_filter)
    error_message = "nat_log_filter должен быть ERRORS_ONLY, TRANSLATIONS_ONLY или ALL."
  }
}
