= Tecnologías e integración de productos de terceros
<tecnologias-e-integracion-de-productos-de-terceros>

En esta sección de la memoria justificaremos las elecciones realizadas en cuestión a las tecnologías, servicios y programas de terceros empleados en el desarrollo de este trabajo. Parte de estos elementos ya se encuentran definidos en la sección de *Arquitectura*.

== Fuentes de datos remotas

A pesar de existir una inmensa cantidad de herramientas online a partir de las que se pueden obtener datos para adicionar a los datasets del proyecto se han decidido escoger las siguientes al presentar una mayor facilidad para su trabajo, además de estar generalmente centradas a nivel europeo.

Para la realización de este TFG se han hecho uso de las siguientes fuentes de datos remotos:
- *Google Earth Engine (GEE):* Se eligió como fuente de imágenes satelitales (Sentinel-2) frente a otras alternativas por los siguientes motivos:
  - Su acceso es gratuito para actividades de investigación y uso no comercial. 
  - Presenta un catálogo de más de 900 datasets públicos, los cuales incluye Setinel-2 ya en formato Level-2A (reflectancia de superficie, con corrección atmosférica aplicada) listo ya para el análisis sin tener que descargar los archivos y sin tener que hacer preprocesamiento en local.
  - Tiene integración con la API oficial de Python a través de la librería `earthengine-api`, que permite ejecutar el procesamiento geoespacial directamente sobre la infraestructura de Google en vez de tener que hacerlo en local. 
- *CDS:* Se eligió como fuente de datos de reanálisis climático (ERA5) por los siguientes motivos:
  - Su cobertura europea es consistente con el ámbito del proyecto SOB4ES.
  - Dispone de un cliente oficial en Python mediante la librería `cdsapi` que se configura con un token de acceso personal y permite la automatización de las descargas directamente desde los scripts de Python.
  - Es un servicio gratuito tras el registro en la plataforma y proporciona los datos en formatos estándar (NetCDF/GRIB), los cuales tienen librerías para procesarlos con facilidad dentro de Python.
- *Copernicus DEM:* Se eligió para la obtención del modelo de elevación digital por lo siguientes motivos:
  - Ofrece resolución de 30 metros a escala global (GLO-30) distribuida como Cloud Optimized GeoTIFF y disponible de forma gratuita al público general.
  - Conexión mediante un bucket público de AWS S3 sin necesidad de autenticación ni registro previo.
  - La estructura empleada por el servidor de AWS S3, simplifica notablemente la integración del mismo en el flujo en comparación con otras fuentes de DEN que exigen credenciales y/o portales de descarga manual.
  
  #colbreak()

== Librerías de procesamiento y modelado

== Otros recursos empleados

== Integridad y reproducibilidad
Todas las tecnologías de terceros descritas, pertenecientes al campo del desarrollo y evaluación de modelos, como también de preparación de modelos, como se indica previamente en la sección de *Arquitectura*, quedarán registrados de forma versionada en un fichero `requirements.txt`.

Dicho fichero se actualizará a lo largo de todo el desarrollo de este TFG, lo que permitirá que en caso de querer reproducir este trabajo se pueda hacer de forma fiel y sin problemas.

Las instrucciones para reproducir todo el proceso se podrán encontrar en la sección de *Manual de Usuario*.
