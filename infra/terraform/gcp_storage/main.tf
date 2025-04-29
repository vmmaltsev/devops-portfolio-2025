provider "google" {
  project     = var.project_id
  region      = var.location
  credentials = var.credentials_file
}

data "google_project" "current" {}

resource "google_kms_key_ring" "tf_state" {
  name     = "tf-state-keyring"
  location = var.location
}

resource "google_kms_crypto_key" "tf_state" {
  name            = "tf-state-key"
  key_ring        = google_kms_key_ring.tf_state.id
  rotation_period = "${var.kms_key_rotation_days * 86400}s"
}

# IAM для Cloud Storage internal SA
resource "google_kms_crypto_key_iam_member" "allow_gcs_service_account" {
  crypto_key_id = google_kms_crypto_key.tf_state.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.current.number}@gs-project-accounts.iam.gserviceaccount.com"
}

# Задержка, чтобы IAM-права успели примениться
resource "time_sleep" "wait_for_kms_iam" {
  depends_on = [
    google_kms_crypto_key_iam_member.allow_gcs_service_account
  ]
  create_duration = "20s"
}

resource "google_storage_bucket" "tf_state" {
  depends_on = [
    time_sleep.wait_for_kms_iam
  ]

  name                        = var.bucket_name
  location                    = var.location
  storage_class               = "STANDARD"
  force_destroy               = false
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }

  encryption {
    default_kms_key_name = google_kms_crypto_key.tf_state.id
  }

  labels = {
    purpose    = "terraform-remote-state"
    managed_by = "terraform"
  }
}
