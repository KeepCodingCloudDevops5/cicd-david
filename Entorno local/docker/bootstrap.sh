#!/bin/bash
# ESTE SCRIPT EJECUTARÁ LOS COMANDOS DE TERRAFORM NECESARIOS, PARA QUE TU PUEDAS ABSTRAERTE DE ELLO :-D
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