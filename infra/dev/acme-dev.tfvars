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
    env = "dev"
    name = "Disco de almacenamiento de ACME - Development"
}

tags_resource_gcp = {
    "env" : "dev"
    "name": "disco_de_almacenamiento_de_acme_development"
}

resource_name = {
  "s3" = "acme-storage-dev-david"
  "gs" = "acme-storage-dev-david"
}
output = json
