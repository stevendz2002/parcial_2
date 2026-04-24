# Parcial 2 - Flutter App

Aplicación móvil en Flutter para gestión de parqueaderos y reportes de accidentes, desarrollada como proyecto parcial universitario.

## 🚀 Estado del Proyecto

✅ **Funcionalidades completadas:**
- Listado de establecimientos con skeleton loading (Shimmer).
- Formulario de creación y edición de establecimientos con subida de imagen.
- Eliminación lógica de establecimientos vía API DELETE.
- Vista de detalle de establecimiento.
- Dashboard principal con reportes y navegación.
- Gráficos estadísticos de accidentes (Barras y Tortas).
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


## 🧠 Notas Técnicas Avanzadas

### Future/async/await vs Isolate
* **Future/async/await:** Se utilizó para todas las peticiones HTTP (I/O Bound). Permite que la app no se bloquee mientras espera la respuesta del servidor, pero sigue ejecutándose en el hilo principal.
* **Isolates:** Se implementaron para el **procesamiento de datos estadísticos**. Dado que el JSON de accidentes puede ser muy extenso, realizar el filtrado y cálculo de promedios en el hilo principal causaría caídas de frames (lag). El Isolate procesa la información en un hilo separado y devuelve solo el resultado listo para graficar.

### Rutas con GoRouter
Se implementó navegación declarativa pasando parámetros:
- **Parámetros de ruta:** Para ver el detalle (`/detalle/:id`).
- **Objetos Extra:** Para pasar el modelo completo al formulario de edición y evitar peticiones innecesarias.

---

## 📸 Evidencias Visuales

### Estadísticas de Accidentes
Procesamiento de datos masivos visualizados en componentes de `fl_chart`.

| Distribución por Barrio y Día | Clase y Gravedad del Accidente |
|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/f334fa66-5623-423d-b077-458cc22d91d1" width="300" /> | <img src="https://github.com/user-attachments/assets/3b31742b-ffdb-460b-adb3-540b0a8d1e2e" width="300" /> |

### Gestión de Establecimientos (CRUD)
Interfaz completa para la administración de parqueaderos.

| Listado General | Detalle del Registro |
|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/034dfce9-5baf-4c7a-9791-9bfc54c19873" width="300" /> | <img src="https://github.com/user-attachments/assets/a274506b-a74b-4896-af93-84b6313fd4ef" width="300" /> |

### Edición y Control
Formularios validados y diálogos de confirmación para acciones críticas.

| Formulario de Edición | Confirmación de Eliminación |
|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/aefb8d93-5c93-4360-8094-fc1be9e5fc15" width="300" /> | <img src="https://github.com/user-attachments/assets/14516bc1-e8ae-4e82-9ccd-10061c91479a" width="300" /> |

---

## 🛠️ Tecnologías Utilizadas

- **Flutter SDK & Dart**
- **Dio:** Cliente HTTP para consumo de APIs.
- **GoRouter:** Manejo de rutas y navegación.
- **Provider:** Gestión de estado simple y eficiente.
- **Fl Chart:** Creación de gráficas dinámicas.
- **Shimmer:** Efecto de carga (skeleton screen).

## 📡 API Endpoints y JSON

### 1. API Accidentes (Datos Abiertos)
**Endpoint:** `GET /resource/ezt8-5wyj.json`  
**Campos clave:** `clase_accidente`, `gravedad`, `barrio`, `cantidad`.

### 2. API Parqueaderos (Propia)
**Endpoint:** `GET /api/establecimientos`  
**Ejemplo de respuesta:**
```json
{
  "id": 123,
  "nombre": "Juan",
  "nit": "123456",
  "direccion": "calle 18",
  "telefono": "3152816942",
  "logo": "[https://dominio.com/logo.png](https://dominio.com/logo.png)"
}
