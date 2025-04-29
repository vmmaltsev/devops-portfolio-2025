variable "project_id" {
  description = "ID проекта GCP"
}

variable "region" {
  description = "Регион GCP"
}

variable "environment" {
  description = "Окружение (dev, staging, prod)"
}

variable "credentials_file" {
  type        = string
  description = "Path to the service account JSON key file"
}