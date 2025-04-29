variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "location" {
  type        = string
  description = "Region for GCS bucket and KMS resources"
  default     = "us-central1"
}

variable "bucket_name" {
  type        = string
  description = "Name of the GCS bucket for storing Terraform remote state"
}

variable "kms_key_rotation_days" {
  type        = number
  default     = 30
  description = "Rotation period in days for the KMS key"
}

variable "credentials_file" {
  type        = string
  description = "Path to the service account JSON key file"
}
