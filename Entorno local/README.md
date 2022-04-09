- Los desarrolladores de ACME han de poder hacer el despliegue desde sus máquinas para el entorno de dev:

  Para que se pueda llevar a cabo el despliegue del entorno de desarrollo desde las máquinas de los desarrolladores, se ha cocinado una imagen docker, permitiendo de esta forma poder ejecutar un contenedor de ésta imagen, que ya tendrá todo lo necesario para poder ejecutar comandos de Terraform y de AWS CLI, y será desde desde este contenedor, aislado de las maquinas de los desarrolladores, desde donde se va a llevar a cabo el despliegue de los recursos de almacenamiento.
  
  La definición de la imagen docker queda registrada de la siguiente manera en un fichero:

**terraform_dev.Dockerfile**

```
FROM ubuntu:20.04

# Se hace uso de un argumento para definir el valor de la variable de entorno que permite no ser preguntado
# al realizar un apt install.
ARG DEBIAN_FRONTEND=noninteractive

# Se define un argumento que almacenará la versión de Terraform a instalar:
ARG TF_VERSION=1.1.7

# Se define la variable de entorno que almacenará la ruta del fichero de credenciales por defecto para GCP:
ENV GOOGLE_APPLICATION_CREDENTIALS=/root/.gcp/cred.json

# Se crea el directorio de trabajo y nos movemos a él:    
WORKDIR /app

# Se instala la paquetería necesaria para tener instalado Terraform y AWS-Cli:
COPY packages.txt .
RUN apt-get update && xargs -a packages.txt apt install -y && \ 
    curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \ 
    apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \ 
    apt-get update && apt-get install terraform=${TF_VERSION} -y

# Clonamos el repositorio de git con la infraestructura de terraform del entorno de desarrollo:
ARG URL_REPO_GITHUB=https://github.com/davidjapo/acme-iaac-aws-gcp-dev--BIS.git
ARG NOMBRE_REPO_GITHUB=acme-iaac-aws-gcp-dev--BIS
RUN git clone ${URL_REPO_GITHUB}
WORKDIR ${NOMBRE_REPO_GITHUB}

# Se copia el script de ejecución del contenedor docker que creará la IaaC "Acme Dev":
COPY bootstrap.sh .
ENTRYPOINT ["./bootstrap.sh"]
CMD [""]
```

En este fichero **terraform_dev.Dockerfile** se parte de una imagen base de Ubuntu, al que se le instala la aplicación de Terraform y de AWS CLI para levantar la IaaC.

La paquetería necesaria esta definida en el fichero **packages.txt** haciendo mención a la versión de cada paquete a instalar, propiciando de esta forma una **buena práctica de trabajo al pinear la versión del paquete**, creando un ambiente consistente ayudando a evitar errores de utilización ante la actuación de estos por la aplicación. **¡¡OJO!!** Las versiones pineadas de los paquetes van acorde con la versión del sistema operativo instalado.

También se lleva a cabo la clonación de un repositorio de Github, correspondiente a la infraestructura de Terraform.  
En este caso al tratarse del entorno de desarrollo, el repositorio contendrá únicamente los ficheros de la infraestructura de desarrollo, y tal y como se observa en la definición del argumento **URL\_REPO\_GITHUB**,se está añadiendo un repositorio por defecto, de esta forma, la imagen ya tendrá todo lo necesario para poder llevar a cabo el despliegue, pero como la url de este repositorio se está guardando en un argumento del fichero Dockerfile, esto permite poder modificar en tiempo de compilación de la imagen, el valor de este argumento, permitiendo cocinar la imagen con un repositorio a demanda del desarrollador.

Al sistema de ficheros de esta imagen se le añade el fichero correspondiente al script de ejecución del despliegue y que está definida en la instrucción **ENTRYPOINT**.

Por defecto, la ejecución del contenedor como tal, no conlleva el levantamiento de la infraestructura, si no que hay que pasarle el argumento apropiado para ello, quedando sobreescrito el valor de cadena vacía de la instrucción **CMD**.

El argumento apropiado para el despliegue de la infraestructura lo podemos encontrar en el siguiente script de ejecución, y que contiene los comandos necesarios de Terraform para su ejecución:

**bootstrap.sh**

```
#!/bin/bash
# ESTE SCRIPT EJECUTARÁ LOS COMANDOS DE TERRAFORM NECESARIOS, PARA QUE TU PUEDAS ABSTRAERTE DE ELLO :-D

#Se definen los nombres de los ficheros que contienen los valores correspondientes a la variables declaradas
#en el fichero variables.tf y que servirán para discriminar el tipo de entorno a desplegar:
FILENAME_TFVARS_DEV='acme-dev.tfvars'
FILENAME_TFVARS_PROD='acme-prod.tfvars'

#Funciones para el entorno de desarrollo:
function dev.apply() {
    terraform init
    terraform apply -var-file=$FILENAME_TFVARS_DEV -auto-approve
}
function dev.plan() {
    terraform init
    terraform plan -var-file=$FILENAME_TFVARS_DEV    
}
function dev.destroy() {
    terraform init
    terraform destroy -var-file=$FILENAME_TFVARS_DEV    
}


#Funciones para el entorno de producción:
function prod.apply() {
    terraform init
    terraform apply -var-file=$FILENAME_TFVARS_PROD
}
function prod.plan() {
    terraform init
    terraform plan -var-file=$FILENAME_TFVARS_PROD    
}
function prod.destroy() {
    terraform init
    terraform destroy -var-file=$FILENAME_TFVARS_PROD    
}


# Se define la sentencia de control que se usará para la utilización del script, en función del argumento que se le
# pase y que llamará a las funciones que correspondan según el argumento:
if [ -z $1 ]; then
  echo ""
  echo "No se ha ejecutado el script porque no se le ha pasado el argumento requerido..."  
  echo ""
  echo "Argumento dev.plan --> Para comprobar el planning de la infraestructura a levantar en el entorno de desarrollo."
  echo "Argumento dev.apply --> Para levantar la infraestructura requerida en el entorno de desarrollo."
  echo "Argumento dev.destroy --> Para destruir la insfraestructura levantada en el entorno de desarrollo (necesita confirmación del usuario)."
  echo ""
  echo "Argumento prod.plan --> Para comprobar el planning de la infraestructura a levantar en el entorno de producción."
  echo "Argumento prod.apply --> Para levantar la infraestructura requerida en el entorno de producción (necesita confirmación del usuario)."
  echo "Argumento prod.destroy --> Para destruir la insfraestructura levantada en el entorno de producción (necesita confirmación del usuario)."
  echo ""
elif [ $1 == dev.plan ]; then
  dev.plan
elif [ $1 == dev.apply ]; then
  dev.apply
elif [ $1 == dev.destroy ]; then
  dev.destroy
elif [ $1 == prod.plan ]; then
  prod.plan
elif [ $1 == prod.apply ]; then
 prod.apply
elif [ $1 == prod.destroy ]; then
  prod.destroy
fi

exit 0
```

En este fichero **bootstrap.sh** se definen las funciones que ejecutarán los comandos de Terraform correspondientes al despliegue de ambas infraestructuras (dev&prod), funciones que serán llamadas dependiendo del argumento que se le pase en la ejecución de este script bash, y que corresponderán con las 3 acciones que realizará Terraform sobre la infraestructura:

 1. plan
: Muestra los cambios requeridos para la configuración de la infraestructura declarada.

 2. apply
: Crea o actualiza la infraestructura.

 3. destroy
: Destruye la infraestructura declarada anteriormente.

En el caso de que al script no le se pasara ningún argumento, la acción del despliegue será nulo.

<br>  

- Quieren que el flujo de despliegue para el entorno de dev sea totalmente automático, sin intervención manual:

  Para llevar a cabo el flujo de despliegue automatizado en el entorno de desarrollo, se ha propuesto llevarlo a cabo mediante MAKE, por lo que se ha elaborado un fichero makefile que contiene los stages correspondientes al despliegue.  
  
  **Los stages declarados** en el siguiente fichero son considerados **IDEMPOTENTES**, ya que **en cada nueva ejecución se producen los mismos resultados**, pudiendo ser repetidos tantas veces como sean necesarios sin causar efectos involuntarios: 

  
**makefile-dev**

```
# Se almacena la ruta relativa donde se ubican los ficheros correspondientes a la infraestructura de desarrollo:
PATH_INFRA_DEV = infra/dev
# Se almacenan las rutas absolutas de los directorios donde se ubican los ficheros correspondientes a las credenciales
#de AWS y GCP:
PATH_CREDENTIALS_AWS = /home/japo/.aws
PATH_CREDENTIALS_GCP = /home/japo/.gcp
# Se define el nombre y tag que tendrá la imagen cocinada:
NAME_DOCKER = magnatedelared/acme_iaac_dev:4.0.0
# Se asigna el nombre del fichero correspondiente a la definción de la imagen a cocinar:
NAME_DOCKERFILE = terraform_dev.Dockerfile
# Se declara el nº de la versión correspondiente a la aplicación Terraform:
TF_VERSION = 1.1.7
# Se guarda la url correspondiente al repositorio de Github a clonar y que contendrá la infraestructura a levantar:
URL_REPO_GITHUB = https://github.com/davidjapo/acme-iaac-aws-gcp-dev--BIS.git
NOMBRE_REPO_GITHUB = acme-iaac-aws-gcp-dev--BIS


# El stage all permite ejecutar de forma secuencial los stages definidos en él mismo. 
# Si algo no funciona, revisa que el stage esté referenciado en all.
all: clean dockerize push integration_test

# Realiza una limpieza para crear el pipeline sin suciedad, eliminando aquellos directorios
# de cachés y temporales varios, además de eliminar la imagen creada en otras ocasiones:
clean:
	@echo ***CLEAN STEP***  ***THIS IS AN OLD STEP***
	cd $(PATH_INFRA_DEV) && rm -rf .terraform .terraform.lock.hcl && docker rmi --force $(NAME_DOCKER) 2> /dev/null

# Se realiza la creación de una imagen Docker para posteriormente ejecutar un contenedor que arranque la App.
# Permite modificar en tiempo de compilación de la imagen, el valor de la variable de entorno donde se ubica el nombre
# del directorio de la infraestructura de Terraform, además de modificar el valor del argumento que almacena la url del repositorio a clonar:
dockerize:
	@echo ***BUILD IMAGE WITH CUSTOMIZE GITHUB REPOSITORY PATH STEP***
	cd docker && \
	docker build -f $(NAME_DOCKERFILE) -t $(NAME_DOCKER) \
	--build-arg URL_REPO_GITHUB=$(URL_REPO_GITHUB) \
	--build-arg NOMBRE_REPO_GITHUB=$(NOMBRE_REPO_GITHUB) .

# Permite modificar en tiempo de compilación de la imagen, el valor del argumento que almacena la versión de Terraform a instalar:
build-tf:
	@echo ***BUILD IMAGE WITH CUSTOMIZE TERRAFORM VERSION STEP***
	cd docker && \
	docker build -f $(NAME_DOCKERFILE) -t $(NAME_DOCKER) \
	--build-arg TF_VERSION=$(TF_VERSION) \
	--build-arg URL_REPO_GITHUB=$(URL_REPO_GITHUB) \
	--build-arg NOMBRE_REPO_GITHUB=$(NOMBRE_REPO_GITHUB) .

# Una vez creada la imagen Docker, se procede a subirla al repositorio del registro canónico de Docker 'Docker Hub'
# Este paso requerirá de credenciales para DockerHub.
push:
	@echo ***PUSH TO DOCKER-HUB STEP***
	docker push $(NAME_DOCKER)

# Se realiza el test de integración, que consiste en eliminar en local la imagen de docker creada anteriormente y
# ejecutar la creación de un contenedor, forzando así la descarga de la imagen desde el registro canónico de Docker.
# Se le pasa un volúmen que contiene las credenciales de AWS y que será montado en el contenedor para uso de Terraform.
# Este paso ejecutará la creación de la infraestructura de Terraform definida, al aplicar un apply en el entorno de
# desarrollo, por lo que es una acción intrusiva.
integration_test:
	@echo ***INTEGRATION TEST DEVELOPMENT ENVIRONMENT STEP***
	docker rmi --force $(NAME_DOCKER) 2> /dev/null && \
	docker run -i --rm -v $(PATH_CREDENTIALS_AWS):/root/.aws \
	-v $(PATH_CREDENTIALS_GCP):/root/.gcp $(NAME_DOCKER) dev.apply


# Se puede consultar el planning de la infraestructura. ¡ATENCION! Este paso no es intrusivo.
# Se comprueba el estado de la infraestructura que se almacena en un bucket S3 de ACME:
plan:
	@echo ***PLANNING IaaC STEP***
	docker rmi --force $(NAME_DOCKER) 2> /dev/null && \
	docker run --rm -v $(PATH_CREDENTIALS_AWS):/root/.aws \
	-v $(PATH_CREDENTIALS_GCP):/root/.gcp $(NAME_DOCKER) dev.plan

# Se puede modificar en tiempo de ejecución del contenedor, el valor de la variable de entorno donde se almacena la ruta
# al archivo de credenciales de GCP:
apply-custom-gcp:
	@echo ***APPLY IaaC WITH CUSTOMIZE GOOGLE ENVIRONMENT VARIABLE STEP***
	docker rmi --force $(NAME_DOCKER) 2> /dev/null && \
	docker run -i --rm -v $(PATH_CREDENTIALS_AWS):/root/.aws \
	-v $(PATH_CREDENTIALS_GCP):/root/.gcp_2022 \
	--env GOOGLE_APPLICATION_CREDENTIALS=/root/.gcp_2022/cred.json $(NAME_DOCKER) dev.apply

#Se destruye la infraestructura creada en el target integration_test:
destroy:
	@echo ***DESTROY IaaC STEP***
	docker rmi --force $(NAME_DOCKER) 2> /dev/null && \
	docker run -i --rm -v $(PATH_CREDENTIALS_AWS):/root/.aws \
	-v $(PATH_CREDENTIALS_GCP):/root/.gcp $(NAME_DOCKER) dev.destroy


# Se accederá al contenedor partiendo de la imagen creada en pasos anteriores, para testing:
access:
	@echo ***ACCESS TO CONTAINER STEP***
	docker run --rm -v $(PATH_CREDENTIALS_AWS):/root/.aws \
	-v $(PATH_CREDENTIALS_GCP):/root/.gcp \
	-it --entrypoint="bash" $(NAME_DOCKER)
```

En este fichero **makefile-dev** se define un primer bloque correspondiente a las variables que se van a utilizar dentro de este archivo, permitiendo centralizar los datos en una única área, referenciando a la variable necesaria en la definición del comando a ejecutar, siguiendo de ésta forma, buenas prácticas a la hora de trabajar.

Se han definido 10 stages, incluido el **stage "all"** que **permite la ejecución secuencial de diferentes stages correspondiente al levantamiento de la infraestructura.**  
Algunos stages se han creado pensando en un sistema escalable y customizable en el tiempo, como por ejemplo el **stage "build-tf"**, que **permite cocinar la imagen docker con una versión de Terraform personalizada por el usuario.**

Para que no exista intervención manual a la hora de desplegar el entorno de desarrollo, y de esta forma hacer que el despliegue sea totalmente automático para los desarrolladores, en el **stage "integration_test"**, que se encarga de la ejecución del contenedor docker, se le pasa el argumento **dev.apply** que se encargará de llamar a la función con mismo nombre del script **bootstrap.sh**, llevando a cabo el levantamiento de la infraestructura, y por consiguiente, la creación de los dispositivos de almacenamiento en ambas nubes.  
Para no ser preguntado por la confirmación del levantamiento de la IaaC por parte de Terraform, se hace uso de la opción **"-auto-approve"** que llevará a cabo la **aprobación de manera automática.**  
  
En el **stage "destroy" NO se hace uso de la opción -auto-approve**, no queremos una destrucción de infraestructura de manera no controlada y accidental :-)

<br>

### Una vez explicado todo lo anterior, se hace aporte de capturas de pantalla con la comprobación de las etapas del proyecto:

1. Se realiza la ejecución del **stage "dockerize"** que **se encarga de cocinar una imagen docker que contendrá todo lo necesario para poder realizar el despliegue:**  
  
  **`make -f makefile-dev dockerize`**

  ![alt text](../capturas/dockerize IaaC.png)  
  
2. Se ejecuta el **stage "push"** para subir la imagen al Registry de imágenes canónico de Docker (Docker hub):

  **`make -f makefile-dev push`**
  
  ![alt text](../capturas/docker-hub-dev.png)  

3. Se levanta la infraestructura requerida al ejecutar el **stage "integration_test"**, comprobando antes que no existen los recursos a levantar y que no existe aún el fichero de estado de Terraform en el bucket S3 configurado:

  **Se comprueba que en el bucket S3 asignado para almacenar el estado de Terraform, no se encuentra ningún fichero todavía:**
  
  ![alt text](../capturas/bucket_state_empy.png)

  **Se comprueba que no existen los recursos a desplegar en ningún proveedor cloud:**
  
  ![alt text](../capturas/recursos-dev-KO.png)

  **Se ejecuta el despliegue de la IaaC:**

  **`make -f makefile-dev integration_test`** 
  
  ![alt text](../capturas/deploy-dev.png)

  **Se comprueba que los recursos desplegados existen:**
  
  ![alt text](../capturas/recursos-dev-OK.png)

  **Se comprueba que el fichero de estado de Terraform a sido creado en el bucket S3 configurado para ello:**
  
  ![alt text](../capturas/bucket_state_OK.png)
  
<br>

- Quieren que las credenciales para desplegar nunca estén guardadas en el código:

  - En el caso del despliegue en local, las credenciales se encuentran en la máquina local del desarrollador.  
  Al ejecutar el **stage "integration_test"**, **se ejecuta el contenedor docker que se encargará de realizar el despliegue**, pero en las **opciones de ejecución** de este contenedor, se le pasa la **opción -v** junto **con las rutas absolutas de los directorios donde se ubican los ficheros correspondientes a las credenciales de AWS y GCP, para realizar un "Bind mount"**, de tal forma, que **las credenciales no quedan almacenadas en ninguna imagen, ni en ningún código**, tan solo habrá referencias a la ruta donde se ubican dichas credenciales.
  
  - En el caso del despliegue mediante los Pipeline de Jenkins, **se almacenan las credenciales necesarias en el gestor de credenciales de Jenkins**, y para hacer uso de ellas, en el fichero Jenkinsfile se crean 3 variables de entorno y nos ayudamos de la función "credentials()" de Terraform.
 
      ![alt text](../capturas/Manage-credentials-jenkins.png)

  Cabe mencionar en este momento, que **la infraestructura de los archivos de Terraform en el entorno de producción, difiere ligeramente con respecto al del entorno de desarrollo**, concretamente en la **configuración correspondiente a las credenciales de los proveedores de Cloud**, y esto es debido a que en el entorno de Jenkins para producción, las credenciales se almacenan en el almacén de Jenkins, por lo que **hay que comentar** las **líneas de código** en los siguientes ficheros.  
   **¡OJO!** tener cuidado con no sobre-escribir los ficheros correspondientes al entorno local.
  
**`infra/prod/providers.tf`**
  
```
provider "aws" {
  #shared_config_files      = var.config_aws.shared_config_files
  #shared_credentials_files = var.config_aws.shared_credentials_files
  #profile = var.config_aws.profile
}
``` 

<br>

**`infra/prod/variables.tf`**

```
# Configuración del proveedor AWS:
variable "config_aws" {
  description = "Propiedades pertenecientes a la configuración del proveedor de cloud 'AWS'."
  type = object({
    #shared_config_files = list(string)
    #shared_credentials_files = list(string)
    #profile = string
  })
}
```

<br>

**`infra/prod/acme-prod.tfvars`**

```
config_aws = {
    #shared_config_files      = ["$${HOME}/.aws/config"]
    #shared_credentials_files = ["$${HOME}/.aws/credentials"]
    #profile = "default"
}
```


<br>
