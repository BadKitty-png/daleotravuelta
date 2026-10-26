# Dale otra vuelta

## 1. Descripción breve
Dale Otra Vuelta es una aplicación móvil desarrollada con Flutter y Dart que busca facilitar la compra, venta, donación e intercambio de productos usados entre personas de Dolores Hidalgo y municipios cercanos del norte de Guanajuato.

La aplicación surge de la necesidad de contar con un espacio más organizado y confiable para publicar y encontrar productos que todavía pueden utilizarse, evitando que terminen guardados o se desperdicien.

Su objetivo es conectar a las personas interesadas en dar una segunda oportunidad a sus objetos, permitiéndoles consultar productos y conocer sus características.

## 2. Los 3 tipos de usuario y sus dashboards
La aplicación Dale Otra Vuelta cuenta con tres tipos de usuario: Usuario, Organización y Administrador. Cada uno tiene un dashboard con información y opciones relacionadas con sus funciones dentro de la aplicación.
###Usuario
Este dashboard permite al usuario consultar productos, explorar publicaciones y acceder a las opciones para publicar sus propios productos. También muestra información como los Eco-puntos, las publicaciones, los intercambios y los chats activos.

###Organización
Este panel está pensado para las organizaciones interesadas en recibir donaciones y reutilizar productos. Muestra información relacionada con las donaciones recibidas, las solicitudes pendientes, los donantes y el material reutilizado.

###Administrador
Este dashboard está orientado a la administración de la plataforma. Muestra indicadores sobre los usuarios, las publicaciones activas, los reportes abiertos y las publicaciones pendientes de revisión.
Los dashboards permiten organizar las opciones de la aplicación de acuerdo con el rol seleccionado por el usuario durante el registro.

## 3. Manejo de estado elegido (y por qué)
Para desarrollar Dale Otra Vuelta se utiliza el manejo de estado integrado de Flutter mediante StatefulWidget y setState(). Esto permite actualizar la interfaz cuando el usuario realiza acciones, como buscar productos, seleccionar filtros o modificar los campos de un formulario.

También se utiliza una clase llamada Sesion para mantener en memoria información básica del usuario, como su nombre, correo electrónico, municipio y rol. De esta manera, la aplicación puede mostrar el dashboard correspondiente al tipo de usuario seleccionado.

Además, se utiliza IndexedStack para organizar la navegación entre las secciones principales, como Inicio, Buscar, Chats y Perfil, conservando el estado de las páginas mientras se navega entre ellas.

Se eligió este método porque es una solución sencilla y adecuada para el prototipo actual. Sin embargo, la información se mantiene principalmente en memoria y no se guarda de forma permanente al cerrar la aplicación.

## 4. Cómo ejecutar la app
###Requisitos:
Flutter SDK instalado.
Dart, incluido con Flutter.
Visual Studio Code.
Extensiones de Flutter y Dart instaladas en Visual Studio Code.
Un dispositivo Android o un emulador configurado.

###Pasos para ejecutar la aplicación

Descargar y descomprimir el proyecto.
-Abrir la carpeta del proyecto en Visual Studio Code.
-Abrir una terminal desde el menú Terminal de Visual Studio Code.
-Ejecutar el siguiente comando para instalar las dependencias:
 flutter pub get
-Conectar un dispositivo Android o iniciar un emulador.
-Comprobar que Flutter reconoce el dispositivo:
 flutter devices
-Ejecutar la aplicación:
 flutter run

Al terminar la compilación, la aplicación se abrirá en el dispositivo o emulador seleccionado.
Nota: también se puede ejecutar en el navegador si el proyecto tiene habilitada la plataforma web.

## 5. Demostración al docente
- Dispositivo/emulador usado: [Android]
- Fecha y modalidad de la demostración: [26/10/2026]
- Modalidad: [Presencial]

## 6. Screenshots
### Splashscreen

![Splashscreen](screenshots/01-Splashscreen.png)

### Autenticación
![Login](screenshots/02-Login.png)

![Login con validación](screenshots/03-Login%28validacion%29.png)

### Dashboards
![Dashboard](screenshots/04-Dashboard.png)

![Dashboard de usuario](screenshots/05-Dashboard-usuario.png)

![Dashboard de organización](screenshots/06-Dashboard-organizacion.png)

![Dashboard de administrador](screenshots/07-Dashboard-administrador.png)

### Listas
![Lista principal](screenshots/08-Lista-principal.png)

![Lista de detalle](screenshots/09-Lista-detalle.png)

![Lista vacía](screenshots/10-Lista-vacia.png)

### Formularios
![Formulario](screenshots/11-Formulario.png)

![Formulario con datos](screenshots/12-Formulario-datos.png)

![Formulario de precio](screenshots/13-Formulario-precio.png)

### Evidencia funcional
![Foto del equipo](screenshots/14-Foto-equipo.jpeg)

### Navegación
![Navegación: inicio de sesión](screenshots/15-Navegacion%28iniciosesion%29.png)

![Navegación: dashboard](screenshots/16-Navegacion%28bashboard%29.png)

![Navegación: búsqueda](screenshots/17-Navegacion%28buscar%29.png)

![Navegación: detalle](screenshots/18-Navegacion%28detalle%29.png)

![Navegación: publicación](screenshots/19-Navegacion%28publicacion%29.png)