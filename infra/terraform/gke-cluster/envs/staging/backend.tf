terraform {
  backend "gcs" {
    bucket  = "tf-remote-state-vmmaltsev-devops-portfolio-meask793-20240429"
    prefix  = "gke/staging"
  }
} 