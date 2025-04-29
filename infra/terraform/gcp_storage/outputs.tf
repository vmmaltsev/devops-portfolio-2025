output "bucket_name" {
  value = google_storage_bucket.tf_state.name
}

output "kms_key_name" {
  value = google_kms_crypto_key.tf_state.id
}

output "location" {
  value = var.location
}
