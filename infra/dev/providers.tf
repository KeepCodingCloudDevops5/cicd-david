provider "aws" {
  shared_config_files      = var.config_aws.shared_config_files
  shared_credentials_files = var.config_aws.shared_credentials_files
  profile = var.config_aws.profile
  region  = var.config_aws.region
}

provider "google" {
  project = var.config_gcp.project
  region  = var.config_gcp.region
  zone    = var.config_gcp.zone
}
