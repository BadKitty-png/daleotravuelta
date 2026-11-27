import 'package:flutter/material.dart';

class PoliticasLegales {
  static const String privacidad = '''
AVISO DE PRIVACIDAD
DALE LA VUELTA

Última actualización: noviembre de 2026.

1. RESPONSABLE DEL TRATAMIENTO DE DATOS

Dale la Vuelta es una aplicación destinada a facilitar la reutilización, intercambio y consulta de productos entre sus usuarios.

El responsable del tratamiento de los datos personales deberá completar sus datos de identificación y contacto antes de publicar este aviso de manera definitiva.

Responsable: [Nombre de la persona u organización responsable].
Correo de contacto: [Correo electrónico de contacto].

2. DATOS PERSONALES QUE PODEMOS RECOPILAR

Durante el uso de la aplicación podemos solicitar o almacenar los siguientes datos:

• Nombre completo.
• Correo electrónico.
• Contraseña de acceso.
• Municipio.
• Tipo de cuenta o perfil seleccionado.

Al utilizar otras funciones de la aplicación, también pueden proporcionarse:

• Información de los productos publicados.
• Fotografías, descripciones y precios.
• Municipio, colonia y referencias de ubicación.
• Coordenadas geográficas, cuando el usuario decida compartirlas.
• Mensajes enviados mediante las funciones de comunicación.
• Productos guardados como favoritos.

3. FINALIDADES DEL USO DE LOS DATOS

Los datos se utilizan para:

• Crear y administrar cuentas de usuario.
• Permitir el inicio y cierre de sesión.
• Identificar el perfil de cada usuario.
• Publicar, consultar y administrar productos.
• Mostrar información de ubicación de los productos cuando corresponda.
• Facilitar la comunicación entre usuarios.
• Guardar productos favoritos.
• Mantener el funcionamiento y la seguridad de la aplicación.

4. UBICACIÓN

La aplicación puede permitir que el usuario comparta información de ubicación para identificar dónde se encuentra un producto.

El usuario puede proporcionar manualmente su municipio y colonia. Si la función está disponible, también puede elegir compartir coordenadas mediante el dispositivo.

La ubicación precisa no debe considerarse obligatoria para utilizar las funciones que no la necesitan.

5. PROTECCIÓN DE LA INFORMACIÓN

Dale la Vuelta debe implementar medidas razonables para proteger los datos personales contra el acceso, uso o modificación no autorizados.

Sin embargo, ningún sistema puede garantizar seguridad absoluta.

6. DERECHOS DEL USUARIO

El usuario puede solicitar información sobre sus datos personales, así como pedir su acceso, rectificación, cancelación u oposición, conforme a la legislación aplicable.

También puede solicitar orientación sobre el tratamiento de sus datos mediante el siguiente contacto:

[Correo electrónico de contacto].

7. CONSERVACIÓN DE LOS DATOS

Los datos se conservarán durante el tiempo necesario para cumplir las finalidades descritas y atender las obligaciones aplicables.

El responsable deberá establecer los procedimientos para atender solicitudes de eliminación de cuentas y datos.

8. CAMBIOS AL AVISO DE PRIVACIDAD

Este aviso puede actualizarse cuando cambien las funciones de la aplicación o las prácticas de tratamiento de datos.

Las modificaciones deberán ponerse a disposición de los usuarios dentro de la aplicación.

Al registrarse, el usuario confirma que tuvo acceso a este aviso de privacidad.
''';

  static const String terminos = '''
TÉRMINOS Y CONDICIONES
DALE LA VUELTA

Última actualización: noviembre de 2026.

1. ACEPTACIÓN

Al crear una cuenta y utilizar Dale la Vuelta, el usuario manifiesta que ha leído y acepta estos términos y condiciones.

Si no está de acuerdo, deberá abstenerse de utilizar la aplicación.

2. DESCRIPCIÓN DEL SERVICIO

Dale la Vuelta es una aplicación que busca fomentar la reutilización y el aprovechamiento de productos, permitiendo a los usuarios publicar, consultar y encontrar artículos.

La aplicación funciona como un medio de conexión entre usuarios.

3. REGISTRO Y CUENTA

Para utilizar determinadas funciones es necesario crear una cuenta.

El usuario se compromete a:

• Proporcionar información verdadera y actualizada.
• Mantener la confidencialidad de su contraseña.
• No utilizar la cuenta de otra persona.
• Notificar cualquier uso no autorizado de su cuenta.

Cada usuario es responsable de las actividades realizadas desde su cuenta.

4. PUBLICACIÓN DE PRODUCTOS

Los usuarios que publiquen productos deberán:

• Proporcionar descripciones claras y verídicas.
• Publicar fotografías que correspondan al producto.
• Indicar precios e información de manera honesta.
• Proporcionar información de ubicación cuando decidan hacerlo.
• Contar con autorización para publicar el contenido que compartan.

No se permite publicar artículos ilegales, información engañosa o contenido que perjudique a otros usuarios.

5. COMUNICACIÓN ENTRE USUARIOS

Los usuarios deben mantener una comunicación respetuosa.

No se permite utilizar las funciones de comunicación para acosar, amenazar, engañar o realizar actividades ilícitas.

6. UBICACIÓN Y DATOS COMPARTIDOS

El usuario decide qué información de ubicación proporciona en sus publicaciones.

Antes de compartir referencias o coordenadas, deberá considerar que otros usuarios podrían consultar esa información.

Se recomienda no publicar domicilios particulares ni datos personales sensibles.

7. RESPONSABILIDAD

Cada usuario es responsable de la información y los productos que publica.

Dale la Vuelta no debe considerarse automáticamente responsable de la calidad, estado, disponibilidad o legalidad de los productos publicados por terceros.

Los usuarios deberán verificar la información y tomar precauciones al realizar intercambios o acuerdos.

8. USO INADECUADO

Está prohibido:

• Utilizar la aplicación para cometer actos ilegales.
• Suplantar la identidad de otras personas.
• Publicar información falsa de manera intencional.
• Intentar acceder sin autorización a cuentas o información.
• Dañar o interferir con el funcionamiento de la aplicación.
• Utilizar la plataforma para acosar o perjudicar a otros usuarios.

9. SUSPENSIÓN DE CUENTAS

Cuando se detecte un uso contrario a estos términos, el responsable de la aplicación podrá revisar el caso y aplicar medidas proporcionales, incluyendo la suspensión o restricción de una cuenta.

10. MODIFICACIONES

Estos términos pueden actualizarse cuando sea necesario.

Los cambios deberán estar disponibles para consulta dentro de la aplicación.

11. CONTACTO

Para dudas, comentarios o solicitudes relacionadas con estos términos, el usuario podrá comunicarse mediante:

[Correo electrónico de contacto].

12. ACEPTACIÓN FINAL

Al marcar la casilla de aceptación durante el registro, el usuario confirma que tuvo la oportunidad de consultar estos términos y que acepta las condiciones de uso de Dale la Vuelta.
''';
}

class DocumentoLegalScreen extends StatelessWidget {
  final String titulo;
  final String contenido;

  const DocumentoLegalScreen({
    super.key,
    required this.titulo,
    required this.contenido,
  });

  static const Color verde = Color(0xFF3D7050);
  static const Color crema = Color(0xFFF7F8F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: crema,
      appBar: AppBar(
        backgroundColor: verde,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          titulo,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE4E8E2)),
            ),
            child: SelectableText(
              contenido,
              style: const TextStyle(
                fontSize: 14,
                height: 1.7,
                color: Color(0xFF303A33),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
