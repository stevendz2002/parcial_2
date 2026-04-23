# Parcial 2 - Flutter App

Aplicación móvil en Flutter para gestión de parqueaderos y reportes de accidentes, desarrollada como proyecto parcial universitario.

##Estado del Proyecto

✅ **Funcionalidades completadas:**
- Listado de establecimientos con skeleton loading
- Formulario de creación y edición de establecimientos con subida de imagen
- Eliminación lógica de establecimientos vía API DELETE
- Vista de detalle de establecimiento
- Dashboard principal con reportes y navegación
- Gráficos estadísticos de accidentes (BubbleChart personalizado)

##  Tecnologías

- **Flutter SDK** (>= 3.x)
- **Dart** (>= 3.x)
- **Dio** (5.x) — Cliente HTTP
- **GoRouter** — Navegación por rutas tipada
- **Provider** — State management
- **Image Picker** — Selección de imágenes
- **Flutter Charts** (fl_chart) — Visualización de datos
- **Shimmer** — Skeleton loading states

## Estructura del Proyecto

```
lib/
├── config/
│   └── env_config.dart       # Variables de entorno y URLs base
├── models/
│   ├── accidente_model.dart   # Modelo de accidentes
│   └── establecimiento_model.dart  # Modelo de establecimientos
├── routes/
│   └── app_router.dart        # Rutas de la app (GoRouter)
├── services/
│   ├── accidentes_service.dart    # API: accidentes
│   └── establecimientos_service.dart  # API: establecimientos
├── themes/
│   └── app_theme.dart         # Tema personalizado
├── views/
│   ├── dashboard_view.dart         # Pantalla principal
│   ├── accidentes_stats_view.dart  # Estadísticas (gráficos)
│   ├── establecimientos_list_view.dart  # Lista CRUD
│   ├── establecimiento_form_view.dart   # Formulario (crear/editar)
│   ├── establecimiento_detail_view.dart # Detalle completo
│   └── widgets/
│       ├── custom_pie_chart.dart
│       └── custom_bar_chart.dart
└── main.dart                  # Punto de entrada
```

## Configuración

### Variables de Entorno

Crear un archivo `.env` en la raíz (ver `.env.example`):

```env
API_ACCIDENTES_URL=https://www.datos.gov.co/resource/ezt8-5wyj.json
API_PARQUEADERO_URL=https://parking.visiontic.com.co/api
API_LOGO_URL=https://parking.visiontic.com.co/logo
```

### Dependencias

```bash
flutter pub get
```

## API Endpoints Usados

| Método | Endpoint                                 | Descripción                      |
|--------|------------------------------------------|----------------------------------|
| GET    | /api/establecimientos                    | Listar todos los establecimientos|
| GET    | /api/establecimientos/{id}               | Obtener un establecimiento       |
| POST   | /api/establecimientos                    | Crear establecimiento con logo   |
| POST   | /api/establecimiento-update/{id}         | Actualizar establecimiento       |
| DELETE | /api/establecimientos/{id}               | Eliminar establecimiento         |
| GET    | /api/accidentes                          | Listar accidentes                |

## Flujo CRUD de Establecimientos

1. **Crear**: Formulario en `/establecimientos/form` → POST `/establecimientos`
2. **Leer**: Lista en `/establecimientos` y detalle en `/establecimientos/detail/{id}`
3. **Actualizar**: Edición desde lista → POST `/establecimiento-update/{id}` (endpoint directo sin method spoofing)
4. **Eliminar**: Botón en vista de detalle → DELETE `/establecimientos/{id}`

## Ejecución

```bash
# Modo desarrollo
flutter run

# Con logs detallados
flutter run --verbose

# Build APK
flutter build apk
```

## Notas Técnicas

- El endpoint de actualización usa **method spoofing** (POST + `_method` field) ya que el backend no expone PUT directo
- El archivo `.env` **no** debe committearse (ya está en `.gitignore`)
- Las imágenes de logos se suben como `MultipartFile` y el servidor retorna URLs procesadas por `_processLogoUrl()`
- Se incluye manejo de errores con `DioException` en todos los servicios

## Scripts Útiles

```bash
# Análisis estático
flutter analyze

# Formateo
flutter format .

# Limpiar caché
flutter clean
```

## Autor

Desarrollado para la asignatura de **Parcial 2** — Universidad/Academia.

## Licencia

Este proyecto es de carácter académico.

---

**Nota:** Este README refleja el estado actual del proyecto después de la corrección del endpoint de actualización y la implementación completa del CRUD.
