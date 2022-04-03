FROM magnatedelared/jenkins_base-agent:1.2.0

# Se hace uso de un argumento para definir el valor de la variable de entorno que permite no ser preguntado al 
#realizar un apt install.
ARG DEBIAN_FRONTEND=noninteractive
# Se define la variable que almacenará la versión de Terraform a instalar:
ARG TF_VERSION=1.1.7
# Se instala la paquetería necesaria para tener instalado Terraform y AWS-Cli:
COPY packages.txt .
RUN apt-get update && xargs -a packages.txt apt install -y && \ 
    curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \ 
    apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \ 
    apt-get update && apt-get install terraform=${TF_VERSION} -y && \
    mkdir /home/jenkins/.aws/
# Se copia el fichero de configuración de AWS:
#COPY .aws/config /home/jenkins/.aws/config
#RUN chown -R jenkins:jenkins /home/jenkins/.aws

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]