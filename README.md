# RunTracker-iOS

Este documento enumera las características de cada apartado de la app. Algunas partes varían respecto a los requisitos establecidos en el enunciado de la práctica, o son mejoras opcionales, o son mejoras propuestas por mí, por lo que esto también queda indicado en este documento.

En [este vídeo de presentación de la app](https://youtu.be/rQ2SbKH3jaw "este vídeo de presentación de la app") se muestran todos los detalles del mismo, quedando este documento como índice y resumen de las caracteríasticas.

## Pantalla "entrenamiento"
- Muestra la distancia recorrida, duración, ritmo y cadencia.
- Permite cambiar el dato que se ve en grande al pulsar sobre él (**mejora opcional**)
- En lugar de parar el entrenamiento manteniendo pulsado el botón de pausa, aparece un nuevo botón para dicho propósito cuando se pulsa el de pausa. Se usan botones flotantes proporcionados por la librería [JJFloatingActionButton](https://github.com/jjochen/JJFloatingActionButton "JJFloatingActionButton") (**variación respecto a los requisitos originales**)
- Se permite navegar por el mapa, alejándonos de la ubicación actual. Cuando lo hacemos, aparece un botón que sirve para volver a centrar el mapa en dicha ubicación. (**mejora propuesta**)
- Cada tramo del recorrido dibujado quedará marcado en su inicio y fin con números indicando el orden cronológico (**mejora propuesta**)
- El tramo del recorrido se dibuja de forma mejorada y más estilizada usando la librería [IVBezierPathRenderer](https://github.com/ivan114/IVBezierPathRenderer "IVBezierPathRenderer") (**mejora propuesta**)
- Los datos de la ruta se almacenan mediante CoreData para poder volver a ver cualquier ruta que se haya hecho previamente (**mejora opcional**)

## Pantalla "historial"
- Muestra todos los entrenamientos realizados anteriormente, ordenador por fecha descendente.
- Al pulsar en cualquier de ellos se muestra el mapa con el zoom ajustado a la ruta realizada.
- Se muestra la fecha, distancia, duración, velocidad media, velocidad máxima y ritmo.
- La ruta se muestra formada por distintos colores según la velocidad de cada tramo. Tonos verdes para velocidades lentas, amarillos para velocidades cercanas a la velocidad media, y rojos para velocidades rápidas. (**mejora propuesta**)

## Pantalla "perfil"
- Contiene la foto del usuario, sexo, edad, peso y altura.
- Permite cambiar cualquier dato al hacer click sobre él.
- Cada dato tiene su propia validación de tipo de datos y valores permitidos.

## Pantalla "ajustes"
- Uso [QuickTableViewController](https://github.com/bcylin/QuickTableViewController "QuickTableViewController") para generar esta pantalla
- Permite configurar 2 tipos distintos de notificaciones: cadencia mínima e intervalos.
- Los intervalos pueden ser por duración o por distancia.
- Las notificaciones sonoras se generan mediante el sitentizador de voz de Apple, indicando datos del entrenamiento (ritmo, duración o cadencia).
- Auto-Pausa: si está activo, el entrenamiento se pausará solo cuando el usuario se detenga.
- Precisión GPS: Aunque el enunciado de la práctica indica que hemos de permitir 3 tipos de precisión (óptima, media y baja), he decidido permitir solo la óptima. Entiendo que usar una precisión baja incrementaría la duración de la batería, pero los resultados del entrenamiento no serían fiables, y la app aparentaría funcionar mal. Antes de tomar esta decisión, quería haber probado la app usándola en el exterior, para determinar los diferentes márgenes de error y ajustarlo bien. Pero dado que debido al estado de alarma no se nos permite salir, no he podido probarlo bien. Así que mi decisión final ha sido dejar el ajuste, pero solo permitir óptima de momento. Más adelante podría retomar el desarrollo de la app e implementar esta característica, sabiendo que consiste en asignar a la propiedad [desiredAccuracy](https://developer.apple.com/documentation/corelocation/cllocationmanager/1423836-desiredaccuracy "desiredAccuracy") uno de [estos valores](https://developer.apple.com/documentation/corelocation/cllocationaccuracy "estos valores") (**variación respecto a los requisitos originales**)
