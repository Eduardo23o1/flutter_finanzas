Aplicativo Flutter para la gestión de transacciones financieras.

---

## Requisitos

* Flutter 3.29.2 (Stable)
* Dart 3.7.2
* Firebase CLI:

```bash
npm install -g firebase-tools
firebase login
```

---

## Configuración de Firebase

1. Crear un proyecto en [Firebase Console](https://console.firebase.google.com/).
2. Habilitar **Authentication** con Email/Password.
4. Desde la raíz del proyecto, correr:

```bash
flutterfire configure
```

5. Seleccionar **Android, iOS y Web** según se necesite.
6. Esto generará el archivo `lib/firebase_options.dart` necesario para inicializar Firebase en tu app.

---

## Configuración del Backend Local

1. Asegúrate de tener corriendo el backend en tu máquina (API REST).
2. En `lib/core/dependency_injection/injection_container.dart` (o donde tengas el `ApiClient`) actualiza la IP:

```dart
const String apiBaseUrl = 'http://TU_IP_LOCAL:8000';
```

* Sustituye `TU_IP_LOCAL` por la IP de tu computador donde corre el backend.
* Esto es necesario para que la app pueda conectarse desde Android, iOS o Web.
* Reinicia la app después de cambiar la IP para que tome la nueva dirección.

---
