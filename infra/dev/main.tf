#El estado se almacena en un bucket S3 de ACME:
terraform {
  backend "s3" {
    bucket = "supercalifragilistico-2022"
    key    = "state/remote-state-acme_iaac-dev"
    region = "eu-west-1"
    shared_credentials_file = "$${HOME}/.aws/credentials"
  }
}

#Creación del recurso bucket S3 en AWS:
resource "aws_s3_bucket" "acme" {
  bucket = var.resource_name.s3
  tags = var.tags_resource_aws
}


#Creación del recurso bucket de cloud storage en GCP:
resource "google_storage_bucket" "acme" {
  name = var.resource_name.gs
  location = var.config_gcp.region
  labels = var.tags_resource_gcp
}