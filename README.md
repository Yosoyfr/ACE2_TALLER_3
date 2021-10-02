# ACE2_TALLER_3
Código para placa Arduino Mega 2560 con Modulo Bluetooth HC-05 para la conexión con una aplicación móvil que envía datos a una REST API

- APP
Aplicacion realizada con Flutter (Android), la cual cuenta con una libreria para la conexion con dispositivos bluetooth y una libreria para poder realizar solicitudes HTTP hacia un servidor.

- ARDUINO
Programa en arduino para enviar buffers de datos a traves de un modulo Bluetooth HC-05.

- SERVER
Web backend application creada con NodeJS y Express para la atencion de solicitudes GET y POST.

- DEPLOY
Dockerfile y docker-compose para el despligue del servidor.
