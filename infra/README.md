# KeepCoding DevOps-V CI/CD Práctica Final - David De la Cruz

La empresa ACME quiere empezar a probar la nube, por lo que vamos a **crear de manera totalmente automatizada** unidades de **almacenamiento en la nube (AWS S3, GCP Cloud Storage)** haciendo uso de la herramienta **Terraform** para la escritura de la IaaC de dichas nubes públicas.

Los requerimientos que nos ha dado ACME son los siguientes:

- Quieren **dos unidades de almacenamiento en cada cloud**, correspondiente a los entornos de desarrollo y producción, cuyos tags son:
	-	**acme-storage-dev**
	-	**acme-storage-prod**
	
	La infraestructura de Terraform quedaría de la siguiente manera:
	
**main.tf**
	
```
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
```

En este fichero **main.tf** se está declarando la infraestructura que tiene que manejar Terraform y que se detalla a continuación:   
 
 1. En el bloque de código correspondiente a **terraform{}** se está declarando que el **BackEnd de Terraform** se va a gestionar mediante un **bucket S3 en AWS** llamado **"supercalifragilistico-2022"** cuyo nombre correspondiente al fichero del estado de Terraform es **"remote-state-acme_iaac-dev"** dentro de la carpeta **"state"** de dicho bucket, ubicado en la región AWS de **"eu-west-1"** que corresponde a Irlanda.
  
    También se declara que el fichero de **credenciales de AWS** está ubicado en la **carpeta .aws del directorio personal del usuario**; necesario para que Terraform pueda acceder a la **lectura/escritura del estado de la infraestructura** y poder tenerlo a buen recaudo en cuanto a **seguridad** se refiere.  
Estos **valores** tienen que estar SI o SI **harcodeados en el código**, en lugar de utilizar referencias a variables, ya que así se expresa en la especificación del lenguaje de configuración de Terraform.

 2. En el bloque de código correspondiente a la creación del recurso  de un **bucket S3 en AWS**, se declara el **nombre que recibirá el bucket** así como los **tags** que acompañan a este recurso.

 3. En el bloque de código correspondiente a la creación del recurso **storage bucket en GCP**, se declara el **nombre que tendrá este bucket**, la **región** donde estará ubicado el bucket y los **tags** que acompañarán a este recurso.  

    Los valores de los argumentos son referencias a las **variables contenidas en el fichero variables.tf**

**providers.tf**

```
provider "aws" {
  shared_config_files	  = var.config_aws.shared_config_files
  shared_credentials_files = var.config_aws.shared_credentials_files
  profile = var.config_aws.profile
  region  = var.config_aws.region
}

provider "google" {
  project = var.config_gcp.project
  region  = var.config_gcp.region
  zone    = var.config_gcp.zone
}
```

En este fichero **providers.tf** se está declarando el proveedor que será necesario utilizar para el despliegue de la IaaC:  

  1. En el bloque de código correspondiente al **provider aws**, se está declarando donde están ubicados los archivos con la configuración personalizada de AWS y con las credenciales, así como también el nombre del perfil de configuración personalizada del que se hará uso por parte de AWS y la región donde se crearán los recursos de forma predeterminada.  
  2. En el bloque de código correspondiente al **provider google**, se está declarando el nombre del proyecto de GCP, así como también la región y la zona donde se crearán los recursos.    

     Los valores de los argumentos son referencias a las **variables contenidas en el fichero variables.tf**

**variables.tf**

```
# Configuración del proveedor AWS:
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
```

En este fichero **variables.tf** se definen los **nombres de las variables** y el **tipo de dato a guardar en dicha variable** y que serán utilizadas por el resto de ficheros de configuración de Terraform, ayudando a la **centralización de los datos del proyecto** de la infraestructura.  

Los valores de estas variables estarán declarados en el **fichero personalizado para el entorno de desarrollo** del cliente ACME con nombre **acme-dev.tfvars**

**acme-dev.tfvars**

```
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
```

En este fichero **acme-dev.tfvars**` se declaran los valores personalizados que contendrán las variables correspondientes al fichero *variables.tf*, de esta forma todos los datos estarán centralizados en este fichero.    
 
*Los valores aquí expuestos no representan un riesgo de seguridad.*


**outputs.tf**

```
output "Nombre-bucket-S3" {
  value = aws_s3_bucket.acme.id
}


output "URL-bucket-googleStorage" {
  value = google_storage_bucket.acme.url
}
```

En este fichero **outputs.tf** se declaran los datos que debe de devolver tras el despliegue de la infraestructura.

**En este caso devolverá el nombre de los recursos que habrán quedado levantados** tras el deploy, que son el nombre del bucket S3 de AWS y el nombre del bucket storage de GCP.

<br>
