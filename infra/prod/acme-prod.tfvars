config_aws = {
    shared_config_files      = ["$${HOME}/.aws/config"]
    shared_credentials_files = ["$${HOME}/.aws/credentials"]
    profile = "default"
    region  = "eu-west-1"
}

config_gcp = {
  project = "maximal-quanta-337913"
  region = "europe-west3"
  zone = "europe-west3-b"
}

tags_resource_aws = {
    env = "prod"
    name = "Disco de almacenamiento de ACME - Production"
}


tags_resource_gcp = {
    "env" : "prod"
    "name": "disco_de_almacenamiento_de_acme_production"
}

resource_name = {
  "s3" = "acme-storage-prod-david"
  "gs" = "acme-storage-prod-david"
}
