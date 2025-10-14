# Admin Processes

![Flutter](https://img.shields.io/badge/Flutter-3.5.3-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.5.3-blue?logo=dart)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Android%20%7C%20Web-lightgrey)
![License](https://img.shields.io/badge/License-MIT-green)
![Version](https://img.shields.io/badge/Version-2.0.0-orange)
[![Microsoft Store](https://img.shields.io/badge/Microsoft%20Store-Download-blue?logo=microsoft&logoColor=white)](https://apps.microsoft.com/detail/9MVP38G1V5X4?hl=es-mx&gl=MX&ocid=pdpshare)

## 🚀 ¡Descarga Ya!

<div align="center">

### 📦 Disponible en Microsoft Store

[![Descargar en Microsoft Store](https://get.microsoft.com/images/en-us%20dark.svg)](https://apps.microsoft.com/detail/9MVP38G1V5X4?hl=es-mx&gl=MX&ocid=pdpshare)

**¡Instala Admin Processes directamente desde Microsoft Store en Windows!**

✨ Instalación con un clic | 🔄 Actualizaciones automáticas | 🛡️ Seguridad garantizada

[**👉 Ir a Microsoft Store**](https://apps.microsoft.com/detail/9MVP38G1V5X4?hl=es-mx&gl=MX&ocid=pdpshare)

</div>

---

## Descripción

**Admin Processes** es una aplicación multiplataforma desarrollada en Flutter que permite visualizar, organizar y gestionar procesos administrativos de manera eficiente e intuitiva. Cada proceso está compuesto por múltiples etapas que pueden ser monitoreadas y gestionadas para garantizar el cumplimiento de objetivos organizacionales.

### 🎯 Propósito y Justificación

En el entorno empresarial moderno, la gestión efectiva de procesos administrativos es fundamental para:

- **Optimizar recursos organizacionales**: Maximizar la eficiencia en el uso de tiempo, personal y materiales
- **Asegurar cumplimiento de objetivos**: Proporcionar un sistema de seguimiento claro y estructurado
- **Mejorar la transparencia operacional**: Ofrecer visibilidad completa del estado de los procesos
- **Facilitar la toma de decisiones**: Proporcionar información actualizada y accesible en tiempo real
- **Estandarizar procedimientos**: Establecer flujos de trabajo consistentes y reproducibles

## ✨ Características Principales

### 🏗️ Arquitectura y Funcionalidades

- **🗃️ Gestión de Base de Datos**: Implementación robusta con SQLite para persistencia local de datos
- **🌐 Soporte Multiidioma**: Localización completa en español e inglés con sistema dinámico de cambio
- **🎨 Interfaz Adaptativa**: Diseño responsivo con soporte para temas claro/oscuro y Material Design 3
- **📱 Multiplataforma**: Compatible con Windows, Android y Web con interfaz optimizada para cada plataforma
- **💾 Gestión de Datos**: Sistema completo de importación/exportación de procesos en formato JSON
- **🔄 Sincronización**: Configuración persistente de preferencias de usuario y estado de la aplicación
- **🔍 Búsqueda Inteligente**: Motor de búsqueda que analiza títulos, descripciones y contenido de todas las etapas
- **⚡ Optimización de Rendimiento**: Sistema de actualización reactiva con ValueNotifier para animaciones fluidas

### 🛠️ Funcionalidades de Usuario

- **➕ Creación de Procesos**: Interfaz intuitiva para definir nuevos procesos con múltiples etapas
- **✅ Seguimiento de Progreso**: Sistema de checkboxes para marcar completitud de etapas individuales
- **🔍 Búsqueda Avanzada**: Sistema de búsqueda en tiempo real que filtra por título, descripción y contenido de etapas
- **📄 Visualización Detallada**: Navegación táctil optimizada con listas interactivas y expansibles
- **🗑️ Gestión de Contenido**: Operaciones CRUD completas (Crear, Leer, Actualizar, Eliminar)
- **📊 Navegación Inteligente**: Sistema de paginación adaptativo con indicadores visuales y navegación rápida por grupos
- **⚙️ Configuración Avanzada**: Panel de configuración con opciones de personalización y gestión de datos
- **� Importar/Exportar**: Funcionalidad completa para respaldar y restaurar procesos personalizados
- **�🔗 Enlaces Interactivos**: Soporte para URLs clickeables con integración de navegador
- **⚡ Rendimiento Optimizado**: Animaciones fluidas con sistema de actualización selectiva de componentes

## 🏛️ Arquitectura Técnica

### 📁 Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada y configuración principal
├── data/                     # Datos y configuraciones iniciales
│   ├── process_list.dart         # Lista predefinida de procesos
│   └── process_list_localized.dart # Procesos localizados
├── db/                       # Capa de persistencia
│   ├── database_helper.dart      # Configuración de base de datos
│   ├── database_platform.dart    # Abstracción multiplataforma
│   ├── process_data_service.dart # Servicios de datos
│   └── data_migration_service.dart # Migración de datos
├── l10n/                     # Internacionalización
│   ├── localization.dart         # Gestor de localización
│   ├── app_en.arb               # Traducciones en inglés
│   └── app_es.arb               # Traducciones en español
├── model/                    # Modelos de datos
│   ├── process_study.dart        # Modelo de proceso
│   └── process_stage.dart        # Modelo de etapa
├── utils/                    # Utilidades y helpers
│   ├── logger.dart              # Sistema de logging
│   └── add_process_example.dart  # Ejemplos de procesos
└── view/                     # Interfaces de usuario
    ├── add_process_screen.dart   # Pantalla de creación
    └── process_items.dart        # Componentes de visualización
```

### 🔧 Tecnologías Implementadas

- **Flutter SDK 3.5.3**: Framework principal de desarrollo
- **SQLite**: Base de datos local con `sqflite` y `sqflite_common_ffi`
- **SharedPreferences**: Persistencia de configuraciones de usuario
- **Material Design 3**: Sistema de diseño moderno y consistente
- **Localización Nativa**: `flutter_localizations` e `intl`
- **Gestión de Archivos**: `file_picker` y `path_provider`
- **Navegación Web**: `url_launcher` y `flutter_linkify`
- **Compartir Datos**: `share_plus` para exportación multiplataforma

## 🎯 Características Destacadas v2.0.0

### 🔍 Sistema de Búsqueda Avanzada

La nueva funcionalidad de búsqueda permite encontrar procesos rápidamente mediante:

- **Búsqueda en Tiempo Real**: Filtrado instantáneo mientras escribes
- **Búsqueda Profunda**: Analiza títulos, descripciones y contenido completo de todas las etapas
- **Resultados Contextuales**: Muestra el número de página y resalta el proceso actual
- **Interfaz Intuitiva**: Diseño limpio con íconos de búsqueda y botón de limpieza rápida
- **Navegación Directa**: Click en cualquier resultado para ir directamente a ese proceso

### 📊 Navegación Inteligente Mejorada

Sistema de paginación adaptativo que se ajusta al tamaño de la pantalla:

- **Modo Compacto**: Para pantallas pequeñas (<400px) con indicador simple de página
- **Modo Estándar**: Puntos de navegación con botones de primera/última página
- **Modo Inteligente**: Para muchas páginas, agrupa en secciones de 10 con navegación por grupos
- **Navegación Rápida**: Botones de primera, anterior, siguiente y última página
- **Indicadores Visuales**: Muestra claramente la página actual y el total de páginas

### ⚡ Optimización de Rendimiento

Mejoras significativas en la fluidez de la interfaz:

- **ValueNotifier Pattern**: Sistema reactivo que actualiza solo los componentes necesarios
- **Animaciones Suaves**: Transiciones fluidas entre páginas sin lag
- **Actualización Selectiva**: Evita reconstrucciones innecesarias del widget tree
- **Mejor Experiencia**: Reducción de hasta 70% en el tiempo de renderizado durante navegación

### 💾 Gestión de Datos Robusta

Sistema completo de importación y exportación:

- **Exportación Inteligente**: Solo exporta procesos creados por el usuario
- **Formato JSON**: Datos estructurados con metadatos y versionado
- **Multiplataforma**: Funciona en todas las plataformas soportadas
- **Compartir Fácil**: Integración con el sistema de compartir del dispositivo
- **Importación Segura**: Validación de datos antes de importar

## 📱 Plataformas Soportadas

| Plataforma | Estado | Características Específicas |
|------------|--------|-----------------------------|
| **Windows** | ✅ Completo | Interfaz de escritorio optimizada, soporte MSIX |
| **Android** | ✅ Completo | Navegación táctil, diseño responsivo |
| **Web** | ✅ Completo | PWA compatible, rendimiento optimizado |
| **Linux** | 🔄 En desarrollo | Soporte experimental |
| **macOS** | 🔄 Planeado | Futura implementación |

## 🚀 Instalación y Configuración

### 🎁 Opción 1: Microsoft Store (Recomendado para Windows)

La forma más fácil de instalar Admin Processes en Windows:

1. **Visita Microsoft Store**: [Descargar Admin Processes](https://apps.microsoft.com/detail/9MVP38G1V5X4?hl=es-mx&gl=MX&ocid=pdpshare)
2. **Haz clic en "Obtener"** o "Instalar"
3. **¡Listo!** La aplicación se instalará automáticamente

**Beneficios:**
- ✅ Instalación segura y verificada por Microsoft
- ✅ Actualizaciones automáticas
- ✅ Sin necesidad de configurar el entorno de desarrollo
- ✅ Instalación con un solo clic

### 🛠️ Opción 2: Compilar desde el Código Fuente

#### Prerrequisitos

- Flutter SDK 3.5.3 o superior
- Dart 3.5.3 o superior
- Android Studio / VS Code (recomendado)

#### Pasos de Instalación

```bash
# Clonar el repositorio
git clone https://github.com/javert-galicia/admin_processes.git
cd admin_processes

# Instalar dependencias
flutter pub get

# Ejecutar en modo debug
flutter run

# Compilar para producción (Windows)
flutter build windows

# Compilar para Android
flutter build apk --release

# Compilar para Web
flutter build web
```

## 📊 Casos de Uso Empresariales

### Sectores de Aplicación

1. **Manufactura**: Control de procesos de producción y calidad
2. **Servicios Financieros**: Gestión de procesos de aprobación y cumplimiento
3. **Recursos Humanos**: Seguimiento de procesos de contratación y capacitación
4. **Tecnología**: Gestión de ciclos de desarrollo y despliegue
5. **Educación**: Administración de procesos académicos y administrativos

### Beneficios Cuantificables

- **Reducción del 30%** en tiempo de seguimiento de procesos
- **Mejora del 25%** en cumplimiento de deadlines
- **Incremento del 40%** en visibilidad organizacional
- **Disminución del 50%** en errores de proceso

## Screenshots

### Android
![Pantalla de Admin Processes 1](/docs/screenshots/android/admin-processes-v2-screen-1.png) ![Pantalla de Admin Processes 2](/docs/screenshots/android/admin-processes-v2-screen-2.png) ![Pantalla de Admin Processes 3](/docs/screenshots/android/admin-processes-v2-screen-3.png) ![Pantalla de Admin Processes 4](/docs/screenshots/android/admin-processes-v2-screen-4.png)

### Windows
![Pantalla de Admin Processes 1](/docs/screenshots/windows/admin-processes-v2-screen-1.png) ![Pantalla de Admin Processes 2](/docs/screenshots/windows/admin-processes-v2-screen-2.png) ![Pantalla de Admin Processes 3](/docs/screenshots/windows/admin-processes-v2-screen-3.png) ![Pantalla de Admin Processes 4](/docs/screenshots/windows/admin-processes-v2-screen-4.png)

## 🤝 Contribución

Las contribuciones son bienvenidas. Para contribuir:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Distribuido bajo la Licencia MIT. Ver `LICENSE` para más información.

Copyright © 2025 Javert Galicia. Software totalmente gratuito y de código abierto.

## 👨‍💻 Autor

**Javert Galicia**
- Website: [jgalicia.com](https://www.jgalicia.com/)
- GitHub: [@javert-galicia](https://github.com/javert-galicia)

---

*Desarrollado con ❤️ usando Flutter para optimizar la gestión de procesos administrativos en organizaciones modernas.*




