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
<img width="1285" height="1100" alt="Splashscreen" src="https://github.com/user-attachments/assets/57f33c20-00fb-4511-ac9f-ded9ba4a1af5" />

### Autenticación
<img width="1287" height="1087" alt="Login" src="https://github.com/user-attachments/assets/0b644997-70ab-4809-ba68-bac48f732f45" />
<img width="1287" height="1092" alt="Login(validacion)" src="https://github.com/user-attachments/assets/849a944e-a6bd-4dcb-abe5-99c6379cec20" />

### Dashboards
<img width="1291" height="1097" alt="Dashboard" src="https://github.com/user-attachments/assets/81291780-e880-4bda-9323-4fba6a2a02b9" />
<img width="1287" height="1105" alt="Dashboard-usuario" src="https://github.com/user-attachments/assets/c64f0e0d-93cb-4375-a535-576109eb4eea" />
<img width="1291" height="1092" alt="Dashboard-organizacion" src="https://github.com/user-attachments/assets/87225686-3ca1-4b66-a7ca-ad7d51ee0854" />
<img width="1287" height="1091" alt="Dashboard-administrador" src="https://github.com/user-attachments/assets/78fa1630-e1b4-495f-9bcb-6329153d2333" />

### Listas
<img width="1282" height="1090" alt="Lista-principal" src="https://github.com/user-attachments/assets/3374b7bc-ad28-4bfc-9505-f40aed830534" />
<img width="1291" height="1101" alt="Lista-detalle" src="https://github.com/user-attachments/assets/0b2fd14b-fbe7-401a-a836-d6ffcf831894" />
<img width="1282" height="1092" alt="Lista-vacia" src="https://github.com/user-attachments/assets/899575db-0034-4297-b169-7e49c7d30b67" />

### Formularios
<img width="1287" height="1106" alt="Formulario" src="https://github.com/user-attachments/assets/49c3d917-9683-4d38-80f6-de923162c52c" />
<img width="1282" height="1087" alt="Formulario-datos" src="https://github.com/user-attachments/assets/cc44ac6e-df84-4ba5-a04f-adc87540791f" />
<img width="1280" height="1102" alt="Formulario-precio" src="https://github.com/user-attachments/assets/424aa040-4dea-463e-aaaa-44599ac834ab" />

### Evidencia funcional
<img width="1600" height="1200" alt="Foto-equipo" src="https://github.com/user-attachments/assets/67988e54-bcd7-4213-8e95-559b00acbbf9" />









