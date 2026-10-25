# Notly
## 1. Descripción breve

Notly es una app móvil hecha en Flutter para compartir apuntes entre compañeros de una area educativa. Cada clase tiene un código; quien se une puede ver, subir, descargar, marcar como favoritos y reportar apuntes. Los apuntes se organizan por materia o unidad.

### Funciones principales:

Registro e inicio de sesión con correo personal y contraseña.

Clases públicas (se entra al instante con el código) y privadas (quien tiene el código envía una solicitud que el docente o el administrador aprueba o rechaza).

Subir apuntes desde el dispositivo (PDF, JPG, PNG, DOCX) o tomando una foto con la cámara, con vista previa antes de publicar.

Visor de PDF e imágenes dentro de la app, y descarga real al dispositivo.

Favoritos, descargas, búsqueda por tema o por nombre del autor, clases ocultas.

Reportes de apuntes y moderación.

Datos guardados en el dispositivo (persisten al cerrar la app).


## 2. Los 3 tipos de usuario y sus dashboards

Una misma cuenta normal puede cambiar entre Alumno y Docente desde el menú de la esquina superior. La cuenta de Administrador es una cuenta aparte.

### Roles

Alumno (cliente)	Cualquier cuenta registrada, en modo Alumno	Inicio con sus clases, Descargas, Favoritos, Perfil	Unirse a clases con código (o solicitar entrada si es privada), ver y compartir el código de la clase, subir apuntes a materias o unidades que ya existen, descargar, marcar favoritos, reportar apuntes. No crea clases, materias ni unidades, y no ve la lista de alumnos inscritos.

Docente (operador)	Cualquier cuenta registrada, en modo Docente	Inicio con las clases que creó, panel Administrar con Mis clases, Solicitudes y Moderación	Crear clases (públicas o privadas), crear materias y unidades, ver alumnos inscritos y sacarlos de la clase, aprobar o rechazar solicitudes, cambiar la privacidad de la clase, borrar apuntes y moderar reportes de sus clases. No se une a clases de otros.

Administrador	Cuenta aparte con permiso de administrador (otro administrador puede otorgarlo o quitarlo)	Panel Administrar con Usuarios, Todas las clases, Solicitudes y Moderación	Gestionar todas las clases, ver todos los usuarios, hacer administrador a otro usuario o quitarle el rol, suspender o reactivar usuarios, resolver solicitudes y reportes de cualquier clase.


## 3. Manejo de estado elegido (y por qué)

Se eligió ChangeNotifier con un almacén único (AppStore) y ListenableBuilder, junto con shared_preferences para guardar los datos.

Un solo almacén central (lib/data/app_store.dart) con usuarios, clases, materias, apuntes, solicitudes, reportes, favoritos y descargas. Todas las pantallas leen del mismo lugar, así lo que sube un alumno aparece en el docente sin duplicar datos.
Reglas de rol en un solo sitio: qué ve y qué puede hacer cada modo (alumno, docente, administrador) se decide en AppStore, no repartido por las pantallas.
Sin dependencias extra: ChangeNotifier y ListenableBuilder vienen con Flutter. Para una app de este tamaño, Provider, Riverpod o Bloc añadirían estructura que no hace falta.
Persistencia simple: el estado se serializa a JSON y se guarda en cada cambio (notifyListeners). Al abrir la app, main() lo carga antes de mostrar la primera pantalla.


## 4. Cómo ejecutar la app

Requisitos: Flutter instalado (flutter doctor sin errores en Android), un emulador Android o un celular con depuración USB.

bash
### 1. Entrar al proyecto
cd notly_app

### 2. Instalar dependencias
flutter pub get
flutter pub add shared_preferences file_saver   # solo si faltan en pubspec.yaml

### 3. Ver dispositivos disponibles
flutter devices

### 4. Ejecutar
flutter run -d <id-del-dispositivo>

Si usas emulador de Android Studio: ábrelo primero (Device Manager) y luego ejecuta flutter run.

### Cuentas de ejemplo (datos de muestra):

Rol	  /    Correo	    /   Contraseña

Alumno - Docente	/noemi@gmail.com	/12345678

Alumno - Docente	/docente@gmail.com	/docente123

Administrador	/admin@gmail.com	/admin123

También puedes crear una cuenta nueva desde Registro; queda disponible como Alumno y Docente.

Dependencias principales: file_picker, image_picker, path_provider, open_filex, pdfrx, shared_preferences, file_saver.

## 5. Demostración al docente
Dispositivo/emulador usado: [Android · Pixel (medium_phone) · Android 36]
Fecha y modalidad de la demostración: [fecha] · [presencial / videollamada]
## 6. Screenshots

### Splashscreen

Splash



### Autenticación

Login 

<img width="366" height="700" alt="Captura de pantalla 2026-10-24 203106" src="https://github.com/user-attachments/assets/7db11b51-4552-46a7-98a8-7face5eabae6" />

Registro

<img width="364" height="697" alt="Captura de pantalla 2026-10-24 203537" src="https://github.com/user-attachments/assets/087e2bff-c1c4-4300-89cb-a8bcabedbbe2" />


### Dashboards

Administrador: Dashboard Admin


<img width="370" height="700" alt="Captura de pantalla 2026-10-24 203641" src="https://github.com/user-attachments/assets/27086d18-bee3-4b83-9198-7f9870f84e5b" />

Alumno: Dashboard Cliente


<img width="368" height="698" alt="Captura de pantalla 2026-10-24 203751" src="https://github.com/user-attachments/assets/c76edb14-b14c-40b5-aae9-a6ee847eed3e" />

Docente: Dashboard Operador


<img width="365" height="699" alt="Captura de pantalla 2026-10-24 203849" src="https://github.com/user-attachments/assets/452b5794-18d6-4207-b094-014bfd97b63f" />


### Listas

Lista principal 


<img width="367" height="698" alt="Captura de pantalla 2026-10-24 203938" src="https://github.com/user-attachments/assets/242abc28-68e2-4a22-ae1c-16dccfc23fe6" />

Lista detalle Estado vacío


<img width="364" height="695" alt="image" src="https://github.com/user-attachments/assets/8404878e-c619-4982-ab0b-0e6d7dee74be" />


### Formularios

Formulario dominio


<img width="365" height="699" alt="image" src="https://github.com/user-attachments/assets/00fa6d74-9735-4d16-a524-3240bedf5312" />


### Evidencia funcional

Foto equipo 




Navegación

<img width="129" height="136" alt="Captura de pantalla 2026-10-24 204410" src="https://github.com/user-attachments/assets/77365c82-c75c-42a6-a766-fecdd8f72b32" />


<img width="368" height="53" alt="image" src="https://github.com/user-attachments/assets/cf565323-24e7-4adf-8a37-65b6d30e71a1" />
