# Blueprint: Gestor de Proyectos y Tareas

## 1. Resumen General

Esta es una aplicación Flutter diseñada para la gestión de proyectos y tareas. Permite a los usuarios crear proyectos, asignarles tareas específicas y, potencialmente, asignar usuarios a esos proyectos. La aplicación utiliza Firebase para la autenticación de usuarios y Cloud Firestore como su base de datos principal, siguiendo una arquitectura limpia y escalable.

## 2. Arquitectura y Diseño

### Base de Datos: Cloud Firestore

La aplicación utiliza Cloud Firestore como única fuente de verdad para los datos dinámicos. La estructura de la base de datos se organiza en las siguientes colecciones de nivel raíz:

-   **`projects`**: Almacena todos los documentos de los proyectos. Cada documento contiene el nombre, la descripción, la fecha de creación y una lista de IDs de los usuarios asignados.
-   **`tasks`**: Contiene todas las tareas. Cada tarea está vinculada a un proyecto a través de un `projectId` y tiene su propia descripción, estado (stage), zona y fechas.
-   **`users`**: Guarda la información de los usuarios registrados, como su correo electrónico y su UID de Firebase Auth.

### Gestión de Estado: Provider

La aplicación emplea el paquete `provider` para la gestión de estado y la inyección de dependencias. Esta elección permite una clara separación entre la lógica de la interfaz de usuario y la lógica de negocio.

-   **`ProjectProvider`**: Gestiona todas las operaciones CRUD (Crear, Leer, Actualizar, Borrar) para los proyectos en Cloud Firestore.
-   **`TaskProvider`**: Se encarga de la lógica de negocio y las operaciones CRUD para las tareas, interactuando con la colección `tasks` de Firestore.
-   **`UserProvider`**: Administra la obtención de la lista de usuarios desde la colección `users`.

### Modelos de Datos

Los datos se estructuran utilizando clases de modelo claras en el directorio `lib/models/`:

-   `Project`: Representa un proyecto con sus propiedades. Incluye métodos (`fromFirestore`, `toFirestore`) para la serialización y deserialización de datos con Firestore.
-   `Task`: Define la estructura de una tarea. También implementa la lógica de conversión `fromFirestore` y `toFirestore`.
-   `User`: Modela a un usuario de la aplicación.

## 3. Características Implementadas

-   **Gestión de Proyectos:**
    -   Creación de nuevos proyectos con nombre, descripción y asignación de usuarios.
    -   Visualización de la lista de todos los proyectos existentes.
    -   Edición y eliminación de proyectos.

-   **Gestión de Tareas:**
    -   Creación de nuevas tareas asociadas a un proyecto.
    -   Asignación de un estado (`Backlog`, `To Do`, etc.), zona y descripción a cada tarea.
    -   Visualización de las tareas agrupadas por proyecto.
    -   Actualización y eliminación de tareas.

-   **Gestión de Usuarios:**
    -   Visualización de la lista de usuarios para asignarlos a proyectos.

## 4. Plan Actual

**Objetivo:** Asegurar la consistencia de la base de datos y corregir errores de `permission_denied`.

**Estado:** **Completado.**

-   **[✓]** Se identificó que la aplicación intentaba escribir en dos bases de datos diferentes (Realtime Database y Cloud Firestore).
-   **[✓]** Se migró el `ProjectProvider` y el modelo `Project` para usar exclusivamente Cloud Firestore.
-   **[✓]** Se migró el `TaskProvider` y el modelo `Task` para usar exclusivamente Cloud Firestore.
-   **[✓]** Se ajustaron los formularios (`AddProjectDialog`, `TaskForm`) para comunicarse correctamente con los *providers* actualizados.
-   **[✓]** Se ha creado este `blueprint.md` para documentar el estado y la arquitectura del proyecto.

La aplicación ahora utiliza de forma consistente Cloud Firestore para toda la persistencia de datos, lo que resuelve los errores de permisos y unifica la arquitectura de datos.
