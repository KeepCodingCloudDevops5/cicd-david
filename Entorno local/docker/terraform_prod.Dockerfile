## añadir terraform y aws cli (AGENTE) para la práctica final. 

FROM ubuntu:20.04
# Se hace uso de un argumento para definir el valor de la variable de entorno que permite no ser preguntado al 
#realizar un apt install.
ARG DEBIAN_FRONTEND=noninteractive
# Se define la variable que almacenará la versión de Terraform a instalar:
ARG TF_VERSION=1.1.7
# Se define la variable que almacenará la ruta del fichero de credenciales por defecto para GCP:
ENV GOOGLE_APPLICATION_CREDENTIALS=/root/.gcp/cred.json
# Se crea el directorio de trabajo y nos movemos a él:    
WORKDIR /app
# Se instala la paquetería necesaria para tener instalado Terraform y AWS-Cli:
COPY packages.txt .
RUN apt-get update && xargs -a packages.txt apt install -y && \ 
    curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \ 
    apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \ 
    apt-get update && apt-get install terraform=${TF_VERSION} -y

# Clonamos el repositorio de git con la infraestructura de terraform del entorno de producción:
ARG URL_REPO_GITHUB=https://github.com/davidjapo/acme-iaac-aws-gcp-prod.git
ARG NOMBRE_REPO_GITHUB=acme-iaac-aws-gcp-prod
RUN git clone ${URL_REPO_GITHUB}
WORKDIR ${NOMBRE_REPO_GITHUB}
# Se copia el script de ejecución del contenedor docker que creará la IaaC "Acme Prod" y realizará un apply:
COPY bootstrap.sh .
ENTRYPOINT ["./bootstrap.sh"]
CMD [""]