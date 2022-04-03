# Configuración del proveedor AWS:
variable "config_aws" {
  description = "Propiedades pertenecientes a la configuración del proveedor de cloud 'AWS'."
  type = object({
    shared_config_files = list(string)
    shared_credentials_files = list(string)
    profile = string
    region  = string
  })
}

# Configuración del proveedor GCP:
variable "config_gcp" {
  description = "Propiedades pertenecientes a la configuración del proveedor de cloud 'GCP'."
  type = object({
    project = string
    region = string
    zone = string
  })
}

#Nombres de los recursos:
variable "resource_name" {
  description = "Almacenar el nombre de los recursos"
  type = map(string)
}

#Etiquetas de los recursos AWS:
variable "tags_resource_aws" {
  description = "Nombres que tendrán los tags de los recursos de AWS"
  type = map(string)
}

#Etiquetas de los recursos GCP:
variable "tags_resource_gcp" {
  description = "Nombres que tendrán los tags de los recursos en GCP"
  type = map(string)
}




