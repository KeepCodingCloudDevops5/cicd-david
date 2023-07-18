# Retroalimentación práctica CI/CD

Hola David,

Primeramente darte las gracias por asistir a todas mis clases, es un placer prepararlas para alumnos como tú.

Tu práctica está __apta__, aquí te dejo algunos detallitos:

  - Gracias por haber hecho una **documentación tan clara y fácil de seguir**. A mi me facilita enormemente el trabajo para corregir y en entornos profesionales como sabes es totalmente crucial.
  - Se ve que tienes **soltura en el uso de las funciones list y map de terraform**, se usan muchísimo así que te felicito.
  - **El uso de los ouputs de terraform le da un valor añadido excepcional a tu práctica** me alegro que te hayas peleado con ello.
  - El nombre del bucket de tu backend s3 creo que es lo mejor que he visto en mucho tiempo.
  - Cierto es que el state de terraform nos da poco lugar a hacer "tuneos" pero con un poco de "maña" podrías tener el mismo bloque de configuración del backend creando dos estados distintos y totalmente independientes. Por ejemplo si no especificas la entrada "key" en el bloque de backend pero luego al hacer init pones como argumento -backend-config='key=state/remote-state-acme_iaac-dev'.
  - **Mención a que has explorado tanto AWS como GCP**, de eso se trata, de contar en nuestra caja de herramientas cuantas más tecnologías mejor.
  - Veo que has creado un **Jenkinsfile tanto de creación como de destrucción, esto también tiene mucho valor**. El número de activos que las empresas tienen en la nube es cada vez mayor y a veces hay tanto descontrol que tienen ahí cosas dejadas que no se usan y causan gasto. Es por esto que tener automatizado el borrado también es de agradecer. Y en los entornos de desarrollo en los que como tú, nos estamos peleando con automatizaciones, poder "volver a probar" teniendo el entorno limpio simplemente corriendo un script es una pena pero no es lo habitual y al final ves a mucha gente perdiendo el tiempo en acciones manuales cuando llega este punto.
  - Tienes las configuraciones de la infraestructura para DEV y para PROD separadas. La ventaja de esto es que los entornos están más desacoplados. La desventaja es que hay más código repetido. Usando terraform workspaces podrías reducir enormemente la cantidad de código teniendo al mismo tiempo los entornos apropiadamente aislados, échale un ojo
  - Te podría resultar interesante esta herramienta para la gestión de versiones de terraform https://github.com/tfutils/tfenv. Yo la uso incluso en imágenes docker.
  - Por último, veo que te falta el fichero de despliegue GHActions ¿es correcto o se me ha pasado?. Esto no afecta a tu nota porque veo que _te has peleado con distintos cloud providers y en sí ya es una práctica completísima_. Lo que te animo es a que en el proximo proyecto en el que tengas opción a usar un sistema de CI/CD que pruebes GHActions o Gitlab CI. Verás que todos los conocimientos que tienes de Jenkins te sirven pero que al mismo tiempo la gestión es mucho menos tediosa.


### Respuesta del feedback mía:

Hola Marta,

Muchísimas gracias por tu retroalimentación.

Estoy muy contento de recibir gratas noticias :-)

- Como bien sabes, la documentación ha sido algo de última hora, pero me he esmerado en ello cada día, practicando Markdown y detallando una y otra vez todo el proceso.
- Me gusta la perfeccionalidad, aunque bien se que puede jugar un punto negativo en el día a día.
- Jeje, si es original el nombre del bucket, momentos de inspiración  :-D moola
- Muchas gracias por tus consejos al respecto de Terraform, es algo nuevo a dominar, y se que aún le puedo sacar más jugo, no me alcanzó el tiempo en esta ocasión, pero poco a poco, que este sector es enorme.
- Es una gozada ver como se despliega la infraestructura ella sola, sin necesidad de hacer uso de la consola UI. ¡Que gran avance!
- En cuanto a la utilización de los workspaces de Terrafom, lo he tenido presente en algún momento de la preparación de la práctica, al darme cuenta que al realizar cambios en el código, también tenía que hacerlos en el otro fichero para el otro entorno, y eso me rechinaba, al darme cuenta que hay que seguir buenas prácticas y no repetirse de esa forma (aunque también observaba que todo estaba aislado y me gustaba).
- En tus clases aprendí que la automatización es la clave de todo. Y mi lema siempre ha sido para estos casos, ¡Para que se invento la Informática entonces!, si no es para aprovecharnos de sus bondades, como la automatización, y nada de hacer las cosas manualmente cuando la computación nos lo hace por nosotros.
- Algunas cosas se me han quedado en el tintero que me hubiese gustado meter en la entrega de la práctica, como la parte de GHActions, la funcionalidad de la gestión de llenado del bucket y de mi cosecha meter un ArtiFactory en la nube.
- Que ganas de empezar a meterle mano de verdad a todas estas herramientas en el día a día de un entorno laboral, ¡¡me encanta!!


