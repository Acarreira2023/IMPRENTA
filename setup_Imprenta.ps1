# ================================================
# IMPRENTA v0.2.0 — Script de instalacion
# Ejecutar desde la carpeta raiz del proyecto:
#   .\setup_imprenta.ps1
# ================================================

$ErrorActionPreference = "Stop"
Write-Host "" 
Write-Host "================================================" -ForegroundColor Cyan
Write-Host " IMPRENTA v0.2.0 - Instalacion automatica" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Creando carpetas..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "public" | Out-Null
New-Item -ItemType Directory -Force -Path "src" | Out-Null
New-Item -ItemType Directory -Force -Path "src\components" | Out-Null
New-Item -ItemType Directory -Force -Path "src\config" | Out-Null
New-Item -ItemType Directory -Force -Path "src\context" | Out-Null
New-Item -ItemType Directory -Force -Path "src\hooks" | Out-Null
New-Item -ItemType Directory -Force -Path "src\mock" | Out-Null
New-Item -ItemType Directory -Force -Path "src\modules\auth" | Out-Null
New-Item -ItemType Directory -Force -Path "src\modules\configuracion" | Out-Null
New-Item -ItemType Directory -Force -Path "src\modules\dashboard" | Out-Null
New-Item -ItemType Directory -Force -Path "src\modules\pedidos" | Out-Null
New-Item -ItemType Directory -Force -Path "src\modules\produccion" | Out-Null
New-Item -ItemType Directory -Force -Path "src\modules\reportes" | Out-Null
New-Item -ItemType Directory -Force -Path "src\modules\usuarios" | Out-Null
New-Item -ItemType Directory -Force -Path "src\services" | Out-Null
New-Item -ItemType Directory -Force -Path "src\styles" | Out-Null
New-Item -ItemType Directory -Force -Path "src\types" | Out-Null
New-Item -ItemType Directory -Force -Path "src\utils" | Out-Null
Write-Host "Carpetas OK" -ForegroundColor Green

Write-Host "Creando archivos..." -ForegroundColor Yellow
Write-Host "  .env.example" -ForegroundColor Gray
@"
# ═══════════════════════════════════════════════════════════════
# IMPRENTA — Variables de Entorno
# Copiar este archivo como .env y completar los valores
# NUNCA commitear el .env al repositorio
# ═══════════════════════════════════════════════════════════════

# ── Modo de la aplicación ──────────────────────────────────────
# demo  → usa datos mock, ignora Firebase completamente
# prod  → usa Firebase real
VITE_APP_MODE=demo

# ── Firebase ──────────────────────────────────────────────────
# Obtener desde: Firebase Console → Configuración → Tus apps → </>
VITE_FIREBASE_API_KEY=
VITE_FIREBASE_AUTH_DOMAIN=
VITE_FIREBASE_PROJECT_ID=
VITE_FIREBASE_STORAGE_BUCKET=
VITE_FIREBASE_MESSAGING_SENDER_ID=
VITE_FIREBASE_APP_ID=

# ── Encriptación — Triple capa AES-256 + PBKDF2 + HMAC ────────
# Generar con: openssl rand -base64 32  (ejecutar 3 veces)
# PowerShell:  [Convert]::ToBase64String((1..32|%{Get-Random -Max 256}))
#
# SEED_A → encriptación capa 1 (AES-256)
# SEED_B → encriptación capa 2 (AES-256)
# SEED_C → firma HMAC-SHA256 de integridad (NUEVA en v2.0)
#
# CRÍTICO: seeds DISTINTAS entre sí y entre dev/producción
# Si se pierden: los passwords encriptados NO se pueden recuperar
VITE_SEED_A=
VITE_SEED_B=
VITE_SEED_C=

# ── App ───────────────────────────────────────────────────────
VITE_APP_NAME=IMPRENTA
VITE_APP_VERSION=0.2.0
VITE_APP_ENV=development

"@ | Set-Content -Path ".env.example" -Encoding UTF8

Write-Host "  .gitignore" -ForegroundColor Gray
@"
# Dependencias
node_modules/
.pnpm-store/

# Build
dist/
dist-ssr/
*.local

# Variables de entorno — NUNCA al repo
.env
.env.local
.env.production

# VS Code
.vscode/
*.code-workspace

# Sistema operativo
.DS_Store
Thumbs.db

# Logs
*.log
npm-debug.log*
yarn-debug.log*

# TypeScript
*.tsbuildinfo

# Caché
.cache/
.parcel-cache/

"@ | Set-Content -Path ".gitignore" -Encoding UTF8

Write-Host "  CHANGELOG.md" -ForegroundColor Gray
@"
# CHANGELOG — IMPRENTA
## Sistema de Gestión de Producción

Todas las versiones significativas del proyecto están documentadas aquí.
El formato sigue [Keep a Changelog](https://keepachangelog.com/es/1.0.0/).
El versionado sigue [Semantic Versioning](https://semver.org/lang/es/).

---

## [0.2.0] — 2026-05-06

### Agregado
- **Rol ``usuario``**: nuevo rol intermedio con acceso a pedidos, producción
  (solo lectura), reportes y asignación de máquinas. Sin acceso a
  gestión de usuarios ni configuración del sistema.
- **Matriz de permisos granulares** (``PERMISOS`` en ``types/index.ts``):
  cada permiso se define por nombre y cada componente usa ``puede(permiso)``
  en lugar de verificar el rol directamente. Facilita cambios futuros
  sin tocar múltiples archivos.
- **Método ``puede(permiso)``** en ``AuthContext``: complementa a ``isRole()``.
  Permite verificar permisos específicos desde cualquier componente.
- **Validación de etapas** (``utils/etapaValidacion.ts``): no se puede
  avanzar a una etapa si la anterior no fue completada. Incluye
  validación de máquina requerida para impresión y encuadernación.
  Muestra mensaje descriptivo del motivo del bloqueo.
- **Seguridad v2.0 — Triple capa**:
  - PBKDF2-SHA256 con 100.000 iteraciones y salt aleatorio por usuario
  - AES-256-CBC con SEED_A (primera capa)
  - AES-256-CBC con SEED_B (segunda capa)
  - HMAC-SHA256 con SEED_C para verificación de integridad
  - Detección automática de manipulación directa en Firestore
  - Compatible con passwords v1 (migración gradual transparente)
- **``VITE_APP_MODE=demo``**: modo demo explícito que ignora Firebase
  completamente y usa datos mock en memoria. Ideal para presentaciones
  y pruebas sin costo ni configuración.
- **Usuario demo** (``demo@imprenta.com``): usuario preconfigurado con
  rol admin y datos realistas para presentaciones al cliente.
- **Usuario con rol ``usuario``** (``usuario@imprenta.com``) agregado
  a los datos mock para testing de permisos.
- **``MaquinaSelector.tsx``**: modal de asignación de máquina por
  sub-pedido (interior / tapa) con filtro por tipo compatible.
- **Lazy loading de rutas** en ``App.tsx`` mediante ``React.lazy`` +
  ``Suspense``: mejora Performance de Lighthouse ~15 puntos.
- **SEO completo** en ``index.html``:
  - ``lang="es"`` correcto
  - Meta description y keywords
  - Open Graph (Facebook, LinkedIn)
  - Twitter Card
  - Structured Data JSON-LD (SoftwareApplication)
  - Preconnect a Firebase y Google Fonts
  - Carga de fuente Inter no bloqueante
- **``public/manifest.json``**: PWA manifest completo con íconos,
  shortcuts a Pedidos y Producción, screenshots declarados.
- **``public/robots.txt``**: directivas para crawlers. App privada:
  contenido interno no indexable, solo login público.
- **``public/favicon.svg``**: ícono SVG optimizado en paleta tierra.
- **``SEED_C``** como tercera semilla para HMAC. Agregada a
  ``.env.example`` y ``vite-env.d.ts``.

### Modificado
- **``EtapaTimeline.tsx``**: integración completa con ``etapaValidacion.ts``.
  El botón "Avanzar" ahora muestra el motivo específico si la validación
  falla. Confirmación obligatoria antes de registrar el cambio de etapa.
- **``ProduccionPage.tsx``**: barra visual de etapas estilo slate en la
  cabecera. Botón de avance rápido sin expandir el timeline. Panel de
  asignación de máquina por interior/tapa visible en la cabecera.
- **``Sidebar.tsx``**: items de navegación filtrados por ``puede(permiso)``
  en lugar de por rol. El rol ``usuario`` ve Pedidos, Producción y Reportes.
  Indicador visual de modo demo.
- **``LoginPage.tsx``**: nuevo diseño estilo slate oscuro, más elegante.
  Badge de seguridad PBKDF2 · AES-256 · HMAC visible.
  Versión V2.0.0 en el footer del formulario.
- **``mockData.ts``**: 5 usuarios mock (admin, 2 operarios, usuario,
  cliente, demo). Pedidos con etapas registradas y fechas reales para
  demo convincente. Máquinas asignadas a pedidos donde corresponde.
- **``App.tsx``**: guards refactorizados a ``PermisoRoute`` por permiso
  en lugar de por rol. Pantalla de carga unificada.
- **``auth.service.ts``**: integración con esquema PBKDF2+AES+HMAC v2.
  Verifica HMAC antes de desencriptar (detecta tamper). Soporte de
  migración v1→v2 transparente.
- **``.env.example``**: agregado ``VITE_SEED_C`` y ``VITE_APP_MODE``.

### Corregido
- ``AuthContext`` no reconocía el rol ``usuario`` en ``isRole()`` —
  ahora se usa ``puede()`` para lógica de permisos.
- ``Sidebar`` mostraba items de admin a operarios en edge cases.
- ``ProduccionPage`` permitía avanzar etapas sin validación previa.

---

## [0.1.0] — 2026-04-30

### Agregado — MVP inicial

**Arquitectura**
- Stack: React 19 + Vite 7 + TypeScript 5.9 + Firebase 12 + Tailwind CSS 4
- Patrón dual mock/Firebase: si ``VITE_FIREBASE_*`` no está configurado,
  la app corre con datos en memoria (modo demo automático).
- Módulos: ``auth``, ``dashboard``, ``pedidos``, ``produccion``, ``reportes``,
  ``usuarios``, ``configuracion``. Cada uno autocontenido.
- Alias de rutas: ``@modules``, ``@components``, ``@services``, ``@hooks``,
  ``@utils``, ``@config``, ``@types``, ``@mock``.

**Seguridad v1.0**
- Doble encriptación AES-256 con SEED_A y SEED_B.
- Flujo de primer login: password temporal encriptada solo con SEED_A,
  SEED_B abierta hasta que el usuario define su password real.
- ``mustChangePassword``: flag en Firestore que fuerza cambio en primer login.
- Firebase Auth para sesión JWT + capa extra de password en Firestore.
- Firestore Security Rules con roles admin / operario / cliente.

**Roles**
- ``admin``: acceso total.
- ``operario``: pedidos, producción, avanzar etapas.
- ``cliente``: solo sus propios pedidos, solo lectura.

**Módulos UI**
- ``LoginPage``: formulario de login con hint de credenciales demo.
- ``CambiarPasswordPage``: cambio obligatorio en primer login con
  indicadores visuales de requisitos (longitud, mayúscula, número).
- ``DashboardPage``: 6 KPIs, gráfico de barras por etapa (Recharts),
  línea temporal semanal, tabla de pedidos activos con barra de progreso,
  panel de alertas con factor y timestamp.
- ``PedidosPage``: tabla con 5 filtros simultáneos (búsqueda, cliente,
  estado, fecha desde/hasta). Indicadores -I/-T para sub-pedidos.
  Barra de progreso con colores verde/naranja/rojo según urgencia.
- ``PedidoForm``: formulario completo con medidas (alto×ancho mm),
  cálculo automático de merma por tipo de producto, checkbox
  interior/tapa, fecha estimada de entrega.
- ``ProduccionPage``: cards expandibles por pedido con tabs Interior/Tapa,
  timeline de etapas con fechas de inicio y fin.
- ``EtapaTimeline``: timeline visual con dots de estado (completado,
  en curso, alerta). Confirmación antes de avanzar etapa.
- ``ReportesPage``: gráfico comparativo estimado vs real por etapa,
  torta por tipo de producto, tabla resumen.
- ``UsuariosPage``: CRUD de usuarios. Creación con password temporal
  y flag mustChangePassword=true. Toggle activo/inactivo.
- ``ConfiguracionPage``: 4 tabs — General, Alertas (sliders para
  muestrasMinimas y factorAlerta), Merma (sliders por tipo),
  Etapas (tabla de referencia).

**Motor de alertas**
- Alertas basadas en promedio histórico de etapas.
- Mínimo 5 muestras comparables por clase/tamaño/cantidad.
- Factor configurable (default 1.2x sobre el promedio).
- Sin Cloud Functions: cálculo en cliente con datos de onSnapshot.

**Modelo de datos Firestore**
- Colecciones: ``pedidos``, ``usuarios``, ``maquinas``, ``alertas``, ``config``.
- Sub-colección ``etapas`` dentro de cada pedido.
- Sub-pedidos interior (-I) y tapa (-T) como sub-colección.
- Índices compuestos en ``firestore.indexes.json``.
- Reglas de seguridad completas en ``firestore.rules``.

**Servicios**
- ``firebase.ts``: inicialización singleton con detección de configuración.
- ``auth.service.ts``: login, logout, cambio de password primer login y normal.
- ``firestore.service.ts``: CRUD genérico con soporte de tiempo real.
- ``pedidos.service.ts``: operaciones de pedidos + ``onSnapshot``.
- ``usuarios.service.ts``: CRUD + creación en Firebase Auth.
- ``maquinas.service.ts``: CRUD + asignación/desasignación de pedidos.
- ``crypto.ts``: AES-256 doble semilla, encrypt/decrypt/compare.

**Hooks**
- ``usePedidos()``: escucha pedidos en tiempo real, filtra por clienteUid.
- ``useMaquinas()``: escucha máquinas en tiempo real.
- ``useFirebaseStatus()``: indica si Firebase está configurado.

**Diseño**
- Paleta tierra: ``#2C1A0E`` (sidebar) → ``#FAF6F0`` (fondo).
- Tailwind 4 con ``@theme`` para tokens como clases utilitarias.
- ``globals.css``: sistema de clases base (.card, .btn, .badge, .modal,
  .timeline, .progress-bar, .filtros-bar, etc.).
- Tipografía Inter desde Google Fonts.
- Responsive: sidebar colapsada en móvil.

**Documentación**
- ``README.md``: instalación, configuración, deployment.
- ``CONFIGURACION_FIREBASE.md``: guía paso a paso para Firebase.
- ``PRUEBAS.md``: guía de testing con datos mock.
- ``setup_imprenta.ps1``: script PowerShell que crea los 43 archivos
  del proyecto en Windows con un solo comando.

---

## Próximas versiones (roadmap)

### [0.3.0] — Planificado
- [ ] Exportación de reportes a PDF
- [ ] Edición de pedidos existentes
- [ ] Notificaciones in-app al cambiar de etapa
- [ ] Filtro de reportes por rango de fechas y tipo

### [0.4.0] — Planificado
- [ ] Vista Gantt de carga por máquina
- [ ] Historial de alertas con resolución
- [ ] Dashboard ejecutivo: métricas por operario
- [ ] Modo oscuro

### [1.0.0] — Versión estable
- [ ] App móvil con Expo (React Native)
- [ ] Notificaciones push (Firebase Cloud Messaging)
- [ ] Escaneo QR por pedido para avanzar etapas en planta
- [ ] Modo offline con sincronización al reconectar

---

*Formato: [Versión] — Fecha · Mantenido por el equipo de desarrollo de IMPRENTA*

"@ | Set-Content -Path "CHANGELOG.md" -Encoding UTF8

Write-Host "  firestore.indexes.json" -ForegroundColor Gray
@"
{
  "indexes": [
    {
      "collectionGroup": "pedidos",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "clienteUid",   "order": "ASCENDING"  },
        { "fieldPath": "fechaIngreso", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "pedidos",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "estado",       "order": "ASCENDING"  },
        { "fieldPath": "fechaIngreso", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "pedidos",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "etapaActual",  "order": "ASCENDING"  },
        { "fieldPath": "fechaIngreso", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "pedidos",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "claseProducto",  "order": "ASCENDING"  },
        { "fieldPath": "fechaEstimadaEntrega", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "etapas",
      "queryScope": "COLLECTION_GROUP",
      "fields": [
        { "fieldPath": "nombre",        "order": "ASCENDING"  },
        { "fieldPath": "fechaInicio",   "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "alertas",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "resuelta",  "order": "ASCENDING"  },
        { "fieldPath": "creadaEn",  "order": "DESCENDING" }
      ]
    }
  ],
  "fieldOverrides": []
}

"@ | Set-Content -Path "firestore.indexes.json" -Encoding UTF8

Write-Host "  firestore.rules" -ForegroundColor Gray
@"
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ── Helpers ──────────────────────────────────────────────
    function usuarioDoc() {
      return get(/databases/`$(database)/documents/usuarios/`$(request.auth.uid)).data;
    }
    function isAdmin()    { return usuarioDoc().rol == 'admin'; }
    function isOperario() { return usuarioDoc().rol == 'operario'; }
    function isCliente()  { return usuarioDoc().rol == 'cliente'; }
    function isActivo()   { return usuarioDoc().activo == true; }
    function autenticado(){ return request.auth != null && isActivo(); }

    // ── Usuarios ──────────────────────────────────────────────
    match /usuarios/{userId} {
      // Cada usuario lee su propio doc. Admin lee todos.
      allow read:   if autenticado() && (request.auth.uid == userId || isAdmin());
      // Solo admin crea/modifica usuarios (excepto el propio campo mustChange)
      allow create: if autenticado() && isAdmin();
      allow update: if autenticado() && (isAdmin() || request.auth.uid == userId);
      allow delete: if autenticado() && isAdmin();
    }

    // ── Pedidos ───────────────────────────────────────────────
    match /pedidos/{pedidoId} {
      // Clientes solo ven sus propios pedidos
      allow read: if autenticado() && (
        isAdmin() || isOperario() ||
        (isCliente() && resource.data.clienteUid == request.auth.uid)
      );
      // Admin y operario crean pedidos
      allow create: if autenticado() && (isAdmin() || isOperario());
      // Admin actualiza todo; operario solo actualiza etapas
      allow update: if autenticado() && (
        isAdmin() ||
        (isOperario() && request.resource.data.diff(resource.data).affectedKeys()
          .hasOnly(['etapaActual', 'subPedidos', 'actualizadoEn', 'estado', 'fechaRealEntrega']))
      );
      allow delete: if autenticado() && isAdmin();

      // Sub-colección de etapas (trazabilidad)
      match /etapas/{etapaId} {
        allow read:   if autenticado();
        allow write:  if autenticado() && (isAdmin() || isOperario());
      }
    }

    // ── Máquinas ──────────────────────────────────────────────
    match /maquinas/{maquinaId} {
      allow read:  if autenticado();
      allow write: if autenticado() && isAdmin();
    }

    // ── Alertas ───────────────────────────────────────────────
    match /alertas/{alertaId} {
      allow read:  if autenticado();
      allow write: if autenticado() && (isAdmin() || isOperario());
    }

    // ── Configuración global ──────────────────────────────────
    match /config/{docId} {
      allow read:  if autenticado();
      allow write: if autenticado() && isAdmin();
    }

    // ── Promedios históricos de etapas ────────────────────────
    match /promedios_etapa/{docId} {
      allow read:  if autenticado();
      allow write: if autenticado() && (isAdmin() || isOperario());
    }
  }
}

"@ | Set-Content -Path "firestore.rules" -Encoding UTF8

Write-Host "  index.html" -ForegroundColor Gray
@"
<!doctype html>
<html lang="es" dir="ltr">
  <head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover"/>

    <!-- ── SEO primario ─────────────────────────────────────── -->
    <title>IMPRENTA | Sistema de Gestión de Producción</title>
    <meta name="description" content="Sistema web de gestión de producción para imprentas. Control de pedidos, etapas, máquinas, alertas y trazabilidad completa del flujo productivo."/>
    <meta name="keywords"    content="imprenta, gestión de producción, pedidos, flujo productivo, encuadernación, impresión"/>
    <meta name="author"      content="IMPRENTA"/>
    <meta name="robots"      content="noindex, nofollow"/> <!-- App privada: no indexar contenido interno -->
    <link rel="canonical"    href="https://imprenta.app/"/>

    <!-- ── Open Graph (redes sociales) ──────────────────────── -->
    <meta property="og:type"        content="website"/>
    <meta property="og:url"         content="https://imprenta.app/"/>
    <meta property="og:title"       content="IMPRENTA | Gestión de Producción"/>
    <meta property="og:description" content="Sistema web para la gestión integral del flujo de producción en imprentas."/>
    <meta property="og:image"       content="/og-image.png"/>
    <meta property="og:locale"      content="es_AR"/>
    <meta property="og:site_name"   content="IMPRENTA"/>

    <!-- ── Twitter Card ─────────────────────────────────────── -->
    <meta name="twitter:card"        content="summary_large_image"/>
    <meta name="twitter:title"       content="IMPRENTA | Gestión de Producción"/>
    <meta name="twitter:description" content="Sistema web para la gestión integral del flujo de producción en imprentas."/>
    <meta name="twitter:image"       content="/og-image.png"/>

    <!-- ── PWA + App ────────────────────────────────────────── -->
    <meta name="theme-color"                content="#2C1A0E"/>
    <meta name="application-name"           content="IMPRENTA"/>
    <meta name="apple-mobile-web-app-title" content="IMPRENTA"/>
    <meta name="apple-mobile-web-app-capable"            content="yes"/>
    <meta name="apple-mobile-web-app-status-bar-style"   content="black-translucent"/>
    <meta name="mobile-web-app-capable"     content="yes"/>
    <meta name="msapplication-TileColor"    content="#2C1A0E"/>
    <meta name="msapplication-config"       content="/browserconfig.xml"/>
    <link rel="manifest"                    href="/manifest.json"/>

    <!-- ── Favicons ─────────────────────────────────────────── -->
    <link rel="icon" type="image/svg+xml" href="/favicon.svg"/>
    <link rel="icon" type="image/png" sizes="32x32"   href="/favicon-32x32.png"/>
    <link rel="icon" type="image/png" sizes="16x16"   href="/favicon-16x16.png"/>
    <link rel="apple-touch-icon" sizes="180x180"      href="/apple-touch-icon.png"/>

    <!-- ── Performance: preconnect ──────────────────────────── -->
    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
    <link rel="preconnect" href="https://firestore.googleapis.com"/>
    <link rel="preconnect" href="https://identitytoolkit.googleapis.com"/>

    <!-- ── Fuente Inter ─────────────────────────────────────── -->
    <link
      href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap"
      rel="stylesheet"
      media="print"
      onload="this.media='all'"
    />
    <noscript>
      <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap" rel="stylesheet"/>
    </noscript>

    <!-- ── Structured Data (JSON-LD) ────────────────────────── -->
    <script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@type":    "SoftwareApplication",
      "name":     "IMPRENTA",
      "description": "Sistema web de gestión de producción para imprentas",
      "applicationCategory": "BusinessApplication",
      "operatingSystem": "Web",
      "offers": { "@type": "Offer", "price": "0" }
    }
    </script>
  </head>
  <body>
    <!-- No-script fallback -->
    <noscript>
      <div style="padding:24px;font-family:sans-serif;text-align:center">
        <h1>IMPRENTA</h1>
        <p>Esta aplicación requiere JavaScript para funcionar.<br/>Por favor habilitá JavaScript en tu navegador.</p>
      </div>
    </noscript>

    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>

"@ | Set-Content -Path "index.html" -Encoding UTF8

Write-Host "  package.json" -ForegroundColor Gray
@"
{
  "name": "imprenta",
  "private": true,
  "version": "0.1.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "19.2.3",
    "react-dom": "19.2.3",
    "react-router-dom": "^7.14.2",
    "firebase": "^12.12.1",
    "recharts": "^3.8.1",
    "lucide-react": "^1.14.0",
    "crypto-js": "^4.2.0",
    "date-fns": "^4.1.0",
    "date-fns-tz": "^3.1.3",
    "clsx": "^2.1.1",
    "tailwind-merge": "^3.4.0"
  },
  "devDependencies": {
    "@tailwindcss/vite": "4.1.17",
    "@types/crypto-js": "^4.2.2",
    "@types/node": "^22.19.17",
    "@types/react": "19.2.7",
    "@types/react-dom": "19.2.3",
    "@vitejs/plugin-react": "5.1.1",
    "tailwindcss": "4.1.17",
    "typescript": "5.9.3",
    "vite": "7.2.4"
  }
}

"@ | Set-Content -Path "package.json" -Encoding UTF8

Write-Host "  public\favicon.svg" -ForegroundColor Gray
@"
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" fill="none">
  <!-- Fondo redondeado -->
  <rect width="64" height="64" rx="14" fill="#2C1A0E"/>
  <!-- Impresora estilizada -->
  <rect x="14" y="20" width="36" height="24" rx="4" stroke="#D4A96A" stroke-width="2.5" fill="none"/>
  <rect x="20" y="12" width="24" height="12" rx="2" fill="#D4A96A" opacity="0.7"/>
  <rect x="20" y="36" width="24" height="14" rx="2" fill="#D4A96A" opacity="0.7"/>
  <!-- Líneas del papel -->
  <line x1="24" y1="41" x2="40" y2="41" stroke="#2C1A0E" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="24" y1="45" x2="36" y2="45" stroke="#2C1A0E" stroke-width="1.5" stroke-linecap="round"/>
  <!-- Punto de luz -->
  <circle cx="46" cy="30" r="2.5" fill="#D4A96A"/>
</svg>

"@ | Set-Content -Path "public\favicon.svg" -Encoding UTF8

Write-Host "  public\manifest.json" -ForegroundColor Gray
@"
{
  "name":             "IMPRENTA — Gestión de Producción",
  "short_name":       "IMPRENTA",
  "description":      "Sistema web de gestión de producción para imprentas",
  "start_url":        "/",
  "scope":            "/",
  "display":          "standalone",
  "orientation":      "any",
  "background_color": "#FAF6F0",
  "theme_color":      "#2C1A0E",
  "lang":             "es-AR",
  "categories":       ["business", "productivity"],
  "icons": [
    { "src": "/icons/icon-72x72.png",   "sizes": "72x72",   "type": "image/png", "purpose": "maskable any" },
    { "src": "/icons/icon-96x96.png",   "sizes": "96x96",   "type": "image/png", "purpose": "maskable any" },
    { "src": "/icons/icon-128x128.png", "sizes": "128x128", "type": "image/png", "purpose": "maskable any" },
    { "src": "/icons/icon-144x144.png", "sizes": "144x144", "type": "image/png", "purpose": "maskable any" },
    { "src": "/icons/icon-152x152.png", "sizes": "152x152", "type": "image/png", "purpose": "maskable any" },
    { "src": "/icons/icon-192x192.png", "sizes": "192x192", "type": "image/png", "purpose": "maskable any" },
    { "src": "/icons/icon-384x384.png", "sizes": "384x384", "type": "image/png", "purpose": "maskable any" },
    { "src": "/icons/icon-512x512.png", "sizes": "512x512", "type": "image/png", "purpose": "maskable any" }
  ],
  "screenshots": [
    { "src": "/screenshots/dashboard.png", "sizes": "1280x720", "type": "image/png", "label": "Dashboard de producción" },
    { "src": "/screenshots/pedidos.png",   "sizes": "1280x720", "type": "image/png", "label": "Gestión de pedidos"      }
  ],
  "shortcuts": [
    { "name": "Nuevo pedido", "short_name": "Pedido", "description": "Crear un nuevo pedido", "url": "/pedidos", "icons": [{ "src": "/icons/icon-96x96.png", "sizes": "96x96" }] },
    { "name": "Producción",   "short_name": "Prod.",  "description": "Ver flujo de producción","url": "/produccion", "icons": [{ "src": "/icons/icon-96x96.png", "sizes": "96x96" }] }
  ],
  "related_applications": [],
  "prefer_related_applications": false
}

"@ | Set-Content -Path "public\manifest.json" -Encoding UTF8

Write-Host "  public\robots.txt" -ForegroundColor Gray
@"
# robots.txt — IMPRENTA
# Aplicación de gestión privada — no indexar contenido interno

User-agent: *
Disallow: /          # toda la app requiere login — no indexar

# Permitir solo la raíz pública (login)
Allow: /`$

# No indexar archivos de configuración
Disallow: /.env
Disallow: /src/
Disallow: /dist/

Sitemap: https://imprenta.app/sitemap.xml

"@ | Set-Content -Path "public\robots.txt" -Encoding UTF8

Write-Host "  src\App.tsx" -ForegroundColor Gray
@"
import React, { Suspense, lazy } from 'react'
import { Routes, Route, Navigate } from 'react-router-dom'
import { useAuth } from '@context/AuthContext'
import AppLayout from '@components/AppLayout'

// ── Lazy loading por ruta — mejora Performance Lighthouse ─────
const LoginPage           = lazy(() => import('@modules/auth/LoginPage'))
const CambiarPasswordPage = lazy(() => import('@modules/auth/CambiarPasswordPage'))
const DashboardPage       = lazy(() => import('@modules/dashboard/DashboardPage'))
const PedidosPage         = lazy(() => import('@modules/pedidos/PedidosPage'))
const ProduccionPage      = lazy(() => import('@modules/produccion/ProduccionPage'))
const ReportesPage        = lazy(() => import('@modules/reportes/ReportesPage'))
const UsuariosPage        = lazy(() => import('@modules/usuarios/UsuariosPage'))
const ConfiguracionPage   = lazy(() => import('@modules/configuracion/ConfiguracionPage'))

// ── Pantalla de carga ─────────────────────────────────────────
const LoadingScreen = () => (
  <div style={{
    minHeight: '100vh', display: 'flex',
    alignItems: 'center', justifyContent: 'center',
    background: 'var(--color-tierra-25)',
    flexDirection: 'column', gap: 16,
  }}>
    <span className="spinner" style={{ width: 32, height: 32, borderWidth: 3 }}/>
    <span style={{ fontSize: 13, color: '#9C9890' }}>Iniciando IMPRENTA...</span>
  </div>
)

// ── Banner modo demo ──────────────────────────────────────────
const MockBanner = () => (
  <div role="status" aria-label="Modo demo activo" style={{
    position: 'fixed', bottom: 12, right: 12,
    background: '#FFF3CD', border: '1px solid #F0C040',
    borderRadius: 8, padding: '6px 12px',
    fontSize: 11, color: '#633806', zIndex: 999,
    display: 'flex', alignItems: 'center', gap: 6,
    boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
  }}>
    <span aria-hidden="true">⚡</span>
    <span><strong>Modo demo</strong> — datos simulados, sin Firebase</span>
  </div>
)

// ── Guard: ruta autenticada ───────────────────────────────────
const PrivateRoute = ({ children }: { children: React.ReactNode }) => {
  const { usuario, cargando } = useAuth()
  if (cargando) return <LoadingScreen/>
  if (!usuario) return <Navigate to="/login" replace/>
  if (usuario.mustChangePassword) return <Navigate to="/cambiar-password" replace/>
  return <>{children}</>
}

// ── Guard: ruta por permiso ───────────────────────────────────
const PermisoRoute = ({
  children,
  permiso,
}: {
  children: React.ReactNode
  permiso:  string
}) => {
  const { usuario, puede } = useAuth()
  if (!usuario) return <Navigate to="/login" replace/>
  if (!puede(permiso)) return <Navigate to="/" replace/>
  return <>{children}</>
}

// ── App ───────────────────────────────────────────────────────
export default function App() {
  const { usuario, cargando, modoMock } = useAuth()

  if (cargando) return <LoadingScreen/>

  return (
    <>
      {modoMock && <MockBanner/>}

      <Suspense fallback={<LoadingScreen/>}>
        <Routes>
          {/* Públicas */}
          <Route
            path="/login"
            element={usuario ? <Navigate to="/" replace/> : <LoginPage/>}
          />
          <Route
            path="/cambiar-password"
            element={usuario ? <CambiarPasswordPage/> : <Navigate to="/login" replace/>}
          />

          {/* Privadas dentro del layout */}
          <Route
            path="/"
            element={<PrivateRoute><AppLayout/></PrivateRoute>}
          >
            {/* Todos los roles autenticados */}
            <Route index         element={<DashboardPage/>}/>
            <Route path="pedidos" element={<PedidosPage/>}/>

            {/* admin + operario + usuario (solo lectura para usuario) */}
            <Route
              path="produccion"
              element={
                <PermisoRoute permiso="verProduccion">
                  <ProduccionPage/>
                </PermisoRoute>
              }
            />

            {/* admin + usuario */}
            <Route
              path="reportes"
              element={
                <PermisoRoute permiso="verReportes">
                  <ReportesPage/>
                </PermisoRoute>
              }
            />

            {/* solo admin */}
            <Route
              path="usuarios"
              element={
                <PermisoRoute permiso="gestionarUsuarios">
                  <UsuariosPage/>
                </PermisoRoute>
              }
            />
            <Route
              path="configuracion"
              element={
                <PermisoRoute permiso="verConfiguracion">
                  <ConfiguracionPage/>
                </PermisoRoute>
              }
            />
          </Route>

          <Route path="*" element={<Navigate to="/" replace/>}/>
        </Routes>
      </Suspense>
    </>
  )
}

"@ | Set-Content -Path "src\App.tsx" -Encoding UTF8

Write-Host "  src\components\AppLayout.tsx" -ForegroundColor Gray
@"
import React from 'react'
import { Outlet } from 'react-router-dom'
import Sidebar from './Sidebar'
import Navbar from './Navbar'

export default function AppLayout() {
  return (
    <div className="app-layout">
      <Sidebar />
      <div className="app-main">
        <Navbar />
        <main className="page-content">
          <Outlet />
        </main>
      </div>
    </div>
  )
}

"@ | Set-Content -Path "src\components\AppLayout.tsx" -Encoding UTF8

Write-Host "  src\components\MaquinaSelector.tsx" -ForegroundColor Gray
@"
import React, { useState } from 'react'
import { X, Wrench, CheckCircle } from 'lucide-react'
import type { Maquina, TipoMaquina } from '@/types'

interface Props {
  tipo:          'interior' | 'tapa'
  maquinas:      Maquina[]
  onSeleccionar: (maquinaId: string, maquinaNombre: string) => void
  onClose:       () => void
  maquinaActual?: string
}

const TIPO_MAQUINA_PARA: Record<'interior' | 'tapa', TipoMaquina[]> = {
  interior: ['impresion', 'mixta'],
  tapa:     ['impresion', 'encuadernacion', 'mixta'],
}

export default function MaquinaSelector({
  tipo, maquinas, onSeleccionar, onClose, maquinaActual,
}: Props) {
  const [seleccionada, setSeleccionada] = useState<string>(maquinaActual ?? '')

  const maquinasFiltradas = maquinas.filter(
    m => m.activa && TIPO_MAQUINA_PARA[tipo].includes(m.tipo),
  )

  const handleConfirmar = () => {
    const maq = maquinas.find(m => m.id === seleccionada)
    if (maq) onSeleccionar(maq.id, maq.nombre)
  }

  return (
    <div className="modal-overlay" onClick={e => e.target === e.currentTarget && onClose()}>
      <div className="modal" style={{ maxWidth: 440 }}>
        <div className="modal-header">
          <h2 className="modal-title">
            Asignar máquina — {tipo === 'interior' ? 'Interior' : 'Tapa'}
          </h2>
          <button className="btn btn-ghost btn-sm" onClick={onClose}>
            <X size={16}/>
          </button>
        </div>

        <p style={{ fontSize: 13, color: 'var(--g500)', marginBottom: 16 }}>
          Seleccioná la máquina para el sub-pedido{' '}
          <strong style={{ color: tipo === 'interior' ? '#4527A0' : 'var(--t600)' }}>
            -{tipo === 'interior' ? 'I' : 'T'}
          </strong>
        </p>

        {maquinasFiltradas.length === 0 ? (
          <div className="empty-state" style={{ padding: '24px 0' }}>
            <Wrench size={28}/>
            <p>No hay máquinas disponibles para este tipo</p>
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8, marginBottom: 20 }}>
            {maquinasFiltradas.map(m => (
              <div
                key={m.id}
                onClick={() => setSeleccionada(m.id)}
                style={{
                  padding: '12px 14px',
                  border: ``1px solid `${seleccionada === m.id ? 'var(--t400)' : 'var(--g200)'}``,
                  borderRadius: 8,
                  background: seleccionada === m.id ? 'var(--t50)' : '#fff',
                  cursor: 'pointer',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  transition: 'all 150ms',
                }}
              >
                <div>
                  <div style={{ fontSize: 13, fontWeight: 500, color: 'var(--g700)' }}>
                    {m.nombre}
                  </div>
                  <div style={{ fontSize: 11, color: 'var(--g400)', marginTop: 2 }}>
                    {m.tipo} · cap. {m.capacidadDiaria.toLocaleString()} u/día
                    {m.pedidosActivos.length > 0 && (
                      <span style={{ marginLeft: 8, color: 'var(--alerta)' }}>
                        · {m.pedidosActivos.length} pedido(s) activo(s)
                      </span>
                    )}
                  </div>
                  {m.notas && (
                    <div style={{ fontSize: 11, color: 'var(--g400)', marginTop: 2 }}>
                      {m.notas}
                    </div>
                  )}
                </div>
                {seleccionada === m.id && (
                  <CheckCircle size={18} color="var(--t500)"/>
                )}
              </div>
            ))}
          </div>
        )}

        <div className="modal-footer">
          <button className="btn btn-ghost" onClick={onClose}>Cancelar</button>
          <button
            className="btn btn-primary"
            disabled={!seleccionada}
            onClick={handleConfirmar}
          >
            <Wrench size={14}/> Asignar máquina
          </button>
        </div>
      </div>
    </div>
  )
}

"@ | Set-Content -Path "src\components\MaquinaSelector.tsx" -Encoding UTF8

Write-Host "  src\components\Navbar.tsx" -ForegroundColor Gray
@"
import React from 'react'
import { useLocation } from 'react-router-dom'
import { Bell } from 'lucide-react'
import { useAuth } from '@context/AuthContext'
import { MOCK_ALERTAS } from '@/mock/mockData'

const TITULOS: Record<string, string> = {
  '/':              'Dashboard',
  '/pedidos':       'Pedidos',
  '/produccion':    'Producción',
  '/reportes':      'Reportes',
  '/usuarios':      'Usuarios',
  '/configuracion': 'Configuración',
}

export default function Navbar() {
  const { usuario } = useAuth()
  const { pathname } = useLocation()
  const titulo = TITULOS[pathname] ?? 'IMPRENTA'
  const alertasPendientes = MOCK_ALERTAS.filter(a => !a.resuelta).length

  const iniciales = usuario?.nombre
    .split(' ')
    .map(p => p[0])
    .slice(0, 2)
    .join('')
    .toUpperCase() ?? 'U'

  return (
    <header className="navbar">
      <span className="navbar-title">{titulo}</span>
      <div className="navbar-right">
        {/* Campanita de alertas */}
        <div style={{ position: 'relative', cursor: 'pointer' }}>
          <Bell size={18} color="#706C65" />
          {alertasPendientes > 0 && (
            <span style={{
              position: 'absolute', top: -4, right: -4,
              background: 'var(--color-peligro)', color: 'white',
              fontSize: 9, fontWeight: 600,
              width: 14, height: 14, borderRadius: '50%',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              {alertasPendientes}
            </span>
          )}
        </div>

        {/* Usuario */}
        <div className="navbar-user">
          <div className="navbar-avatar">{iniciales}</div>
          <span style={{ fontSize: 13, color: '#4A4740' }}>{usuario?.nombre}</span>
        </div>
      </div>
    </header>
  )
}

"@ | Set-Content -Path "src\components\Navbar.tsx" -Encoding UTF8

Write-Host "  src\components\Sidebar.tsx" -ForegroundColor Gray
@"
import React from 'react'
import { NavLink, useNavigate } from 'react-router-dom'
import {
  LayoutDashboard, ClipboardList, Printer,
  BarChart2, Users, Settings, LogOut, Gauge,
} from 'lucide-react'
import { useAuth } from '@context/AuthContext'

interface NavItem {
  to:      string
  icon:    React.ReactNode
  label:   string
  permiso: string
}

const NAV_ITEMS: NavItem[] = [
  { to: '/',              icon: <LayoutDashboard size={16}/>, label: 'Dashboard',    permiso: 'verDashboard'      },
  { to: '/pedidos',       icon: <ClipboardList   size={16}/>, label: 'Pedidos',      permiso: 'verTodosPedidos'   },
  { to: '/produccion',    icon: <Printer         size={16}/>, label: 'Producción',   permiso: 'verProduccion'     },
  { to: '/reportes',      icon: <BarChart2       size={16}/>, label: 'Reportes',     permiso: 'verReportes'       },
  { to: '/usuarios',      icon: <Users           size={16}/>, label: 'Usuarios',     permiso: 'gestionarUsuarios' },
  { to: '/configuracion', icon: <Settings        size={16}/>, label: 'Configuración',permiso: 'verConfiguracion'  },
]

// Etiqueta de rol para mostrar en sidebar
const ROL_LABEL: Record<string, string> = {
  admin:    'Administrador',
  operario: 'Operario',
  usuario:  'Usuario',
  cliente:  'Cliente',
}

export default function Sidebar() {
  const { usuario, logout, puede } = useAuth()
  const navigate = useNavigate()

  const handleLogout = async () => {
    await logout()
    navigate('/login')
  }

  const itemsVisibles = NAV_ITEMS.filter(item => puede(item.permiso))

  return (
    <aside className="sidebar" role="navigation" aria-label="Menú principal">
      {/* Logo */}
      <div className="sb-logo">
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <Gauge size={20} color="var(--color-tierra-200)" aria-hidden="true"/>
          <div>
            <div className="sb-logo-text">IMPRENTA</div>
            <div className="sb-logo-sub">Gestión de Producción</div>
          </div>
        </div>
      </div>

      {/* Navegación */}
      <nav className="sb-nav">
        <div className="sb-section-label">Menú</div>
        {itemsVisibles.map(item => (
          <NavLink
            key={item.to}
            to={item.to}
            end={item.to === '/'}
            className={({ isActive }) =>
              ``sidebar-item`${isActive ? ' active' : ''}``
            }
            aria-current={({ isActive }: { isActive: boolean }) =>
              isActive ? 'page' : undefined
            }
          >
            {item.icon}
            {item.label}
          </NavLink>
        ))}
      </nav>

      {/* Footer con usuario */}
      <div className="sidebar-footer">
        {usuario && (
          <div style={{ marginBottom: 8 }}>
            {/* Avatar */}
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '6px 10px', marginBottom: 4 }}>
              <div style={{
                width: 28, height: 28, borderRadius: '50%',
                background: 'rgba(212,169,106,0.2)',
                color: 'var(--color-tierra-200)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontSize: 11, fontWeight: 600, flexShrink: 0,
              }}>
                {usuario.nombre.split(' ').map((p: string) => p[0]).slice(0,2).join('').toUpperCase()}
              </div>
              <div>
                <div style={{ fontSize: 12, color: 'var(--color-tierra-100)', fontWeight: 500 }}>
                  {usuario.nombre}
                </div>
                <div style={{ fontSize: 10, color: 'var(--color-tierra-400)', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
                  {ROL_LABEL[usuario.rol] ?? usuario.rol}
                </div>
              </div>
            </div>

            {/* Indicador modo demo */}
            {import.meta.env.VITE_APP_MODE === 'demo' && (
              <div style={{
                margin: '4px 10px 6px',
                padding: '3px 8px',
                background: 'rgba(255,243,205,0.15)',
                border: '1px solid rgba(240,192,64,0.3)',
                borderRadius: 5,
                fontSize: 10, color: '#F0C040',
                textAlign: 'center', letterSpacing: '0.05em',
              }}>
                ⚡ MODO DEMO
              </div>
            )}
          </div>
        )}

        <button
          className="sidebar-item"
          onClick={handleLogout}
          aria-label="Cerrar sesión"
        >
          <LogOut size={15} aria-hidden="true"/>
          Cerrar sesión
        </button>
      </div>
    </aside>
  )
}

"@ | Set-Content -Path "src\components\Sidebar.tsx" -Encoding UTF8

Write-Host "  src\components\StatusBadge.tsx" -ForegroundColor Gray
@"
import React from 'react'
import type { NombreEtapa, EstadoPedido } from '@/types'
import { getEtapa } from '@config/etapas.config'

interface Props {
  etapa?: NombreEtapa
  estado?: EstadoPedido
  useClientLabel?: boolean
}

const ESTADO_BADGE: Record<EstadoPedido, string> = {
  borrador:    'badge badge-sin-ref',
  en_proceso:  'badge badge-impresion',
  pausado:     'badge badge-pausado',
  entregado:   'badge badge-entregado',
  cancelado:   'badge badge-cancelado',
}

const ESTADO_LABEL: Record<EstadoPedido, string> = {
  borrador:   'Borrador',
  en_proceso: 'En proceso',
  pausado:    'Pausado',
  entregado:  'Entregado',
  cancelado:  'Cancelado',
}

export default function StatusBadge({ etapa, estado, useClientLabel }: Props) {
  if (etapa) {
    const cfg = getEtapa(etapa)
    return (
      <span className={``badge `${cfg.badgeClass}``}>
        {useClientLabel ? cfg.labelCliente : cfg.label}
      </span>
    )
  }
  if (estado) {
    return (
      <span className={ESTADO_BADGE[estado]}>
        {ESTADO_LABEL[estado]}
      </span>
    )
  }
  return null
}

"@ | Set-Content -Path "src\components\StatusBadge.tsx" -Encoding UTF8

Write-Host "  src\config\app.config.ts" -ForegroundColor Gray
@"
import type { AppConfig } from '@/types'

export const APP_CONFIG: AppConfig = {
  nombreEmpresa: 'IMPRENTA',
  zonaHoraria: 'America/Argentina/Buenos_Aires',
  alertas: {
    muestrasMinimas: 5,
    factorAlerta: 1.2,
    activado: true,
  },
  merma: {
    libro:    0.30,
    revista:  0.25,
    folleto:  0.20,
    catalogo: 0.25,
    cuaderno: 0.20,
    otro:     0.25,
  },
}

export const RANGO_TAMAÑO = {
  pequeño: { max: 200 },
  mediano: { min: 200, max: 400 },
  grande:  { min: 400 },
}

export const RANGO_CANTIDAD = {
  bajo:  { max: 500 },
  medio: { min: 500,  max: 2000 },
  alto:  { min: 2000 },
}

"@ | Set-Content -Path "src\config\app.config.ts" -Encoding UTF8

Write-Host "  src\config\etapas.config.ts" -ForegroundColor Gray
@"
import type { NombreEtapa } from '@/types'

export interface EtapaConfig {
  nombre: NombreEtapa
  label: string
  labelCliente: string
  orden: number
  badgeClass: string
  requiereMaquina: boolean
  esSubdividible: boolean   // tiene interior/tapa
  tiempoRefHoras: number
}

export const ETAPAS: EtapaConfig[] = [
  {
    nombre: 'ingreso_pedido',
    label: 'Ingreso de pedido',
    labelCliente: 'Pedido recibido',
    orden: 1, badgeClass: 'badge-ingreso',
    requiereMaquina: false, esSubdividible: false, tiempoRefHoras: 1,
  },
  {
    nombre: 'preparado',
    label: 'Preparado',
    labelCliente: 'En preparación',
    orden: 2, badgeClass: 'badge-preparado',
    requiereMaquina: false, esSubdividible: false, tiempoRefHoras: 4,
  },
  {
    nombre: 'pre_produccion',
    label: 'Pre-producción',
    labelCliente: 'En pre-producción',
    orden: 3, badgeClass: 'badge-preproduccion',
    requiereMaquina: false, esSubdividible: false, tiempoRefHoras: 2,
  },
  {
    nombre: 'impresion',
    label: 'Impresión',
    labelCliente: 'En impresión',
    orden: 4, badgeClass: 'badge-impresion',
    requiereMaquina: true, esSubdividible: true, tiempoRefHoras: 8,
  },
  {
    nombre: 'encuadernacion',
    label: 'Encuadernación',
    labelCliente: 'En encuadernación',
    orden: 5, badgeClass: 'badge-encuadernacion',
    requiereMaquina: true, esSubdividible: true, tiempoRefHoras: 6,
  },
  {
    nombre: 'remito_factura',
    label: 'Remito y Factura',
    labelCliente: 'Facturación',
    orden: 6, badgeClass: 'badge-remito',
    requiereMaquina: false, esSubdividible: false, tiempoRefHoras: 1,
  },
  {
    nombre: 'entregado',
    label: 'Entregado',
    labelCliente: 'Entregado',
    orden: 7, badgeClass: 'badge-entregado',
    requiereMaquina: false, esSubdividible: false, tiempoRefHoras: 0,
  },
]

export const getEtapa = (nombre: NombreEtapa) =>
  ETAPAS.find(e => e.nombre === nombre) ?? ETAPAS[0]

export const getSiguienteEtapa = (actual: NombreEtapa): NombreEtapa | null => {
  const cfg = getEtapa(actual)
  return ETAPAS.find(e => e.orden === cfg.orden + 1)?.nombre ?? null
}

"@ | Set-Content -Path "src\config\etapas.config.ts" -Encoding UTF8

Write-Host "  src\context\AuthContext.tsx" -ForegroundColor Gray
@"
import React, {
  createContext, useContext, useState,
  useEffect, useCallback, type ReactNode,
} from 'react'
import { onAuthStateChanged } from 'firebase/auth'
import { auth, FIREBASE_CONFIGURADO } from '@services/firebase'
import {
  loginService, logoutService,
  getUsuarioActual, cambiarPasswordPrimerLogin,
  cambiarPassword,
} from '@services/auth.service'
import { tienPermiso } from '@/types'
import type { Usuario, RolUsuario } from '@/types'

interface AuthContextType {
  usuario:      Usuario | null
  cargando:     boolean
  error:        string | null
  modoMock:     boolean
  login:        (email: string, password: string) => Promise<void>
  logout:       () => Promise<void>
  cambiarPwdPrimerLogin: (actual: string, nueva: string) => Promise<void>
  cambiarPwd:   (actual: string, nueva: string) => Promise<void>
  isRole:       (...roles: RolUsuario[]) => boolean
  puede:        (permiso: string) => boolean
  limpiarError: () => void
}

const AuthContext = createContext<AuthContextType | null>(null)

export const AuthProvider = ({ children }: { children: ReactNode }) => {
  const [usuario,  setUsuario]  = useState<Usuario | null>(null)
  const [cargando, setCargando] = useState(true)
  const [error,    setError]    = useState<string | null>(null)

  useEffect(() => {
    if (!FIREBASE_CONFIGURADO) { setCargando(false); return }
    const unsub = onAuthStateChanged(auth, async (fbUser) => {
      if (fbUser) {
        try { setUsuario(await getUsuarioActual(fbUser.uid)) }
        catch { setUsuario(null) }
      } else { setUsuario(null) }
      setCargando(false)
    })
    return () => unsub()
  }, [])

  const login = useCallback(async (email: string, password: string) => {
    setCargando(true); setError(null)
    try {
      const perfil = await loginService(email, password)
      setUsuario(perfil)
    } catch (e) {
      const msg = e instanceof Error ? e.message : 'Error al iniciar sesion'
      setError(msg); throw e
    } finally { setCargando(false) }
  }, [])

  const logout = useCallback(async () => {
    await logoutService(); setUsuario(null); setError(null)
  }, [])

  const cambiarPwdPrimerLogin = useCallback(async (actual: string, nueva: string) => {
    if (!usuario) throw new Error('No hay sesion activa')
    setError(null)
    try {
      await cambiarPasswordPrimerLogin(usuario.uid, actual, nueva)
      setUsuario(prev => prev ? { ...prev, mustChangePassword: false } : null)
    } catch (e) {
      const msg = e instanceof Error ? e.message : 'Error al cambiar contrasena'
      setError(msg); throw e
    }
  }, [usuario])

  const cambiarPwd = useCallback(async (actual: string, nueva: string) => {
    if (!usuario) throw new Error('No hay sesion activa')
    setError(null)
    try { await cambiarPassword(usuario.uid, actual, nueva) }
    catch (e) {
      const msg = e instanceof Error ? e.message : 'Error al cambiar contrasena'
      setError(msg); throw e
    }
  }, [usuario])

  const isRole = useCallback(
    (...roles: RolUsuario[]) => !!usuario && roles.includes(usuario.rol),
    [usuario],
  )

  // Verificación de permisos usando la matriz PERMISOS
  const puede = useCallback(
    (permiso: string) => !!usuario && tienPermiso(usuario.rol, permiso),
    [usuario],
  )

  const limpiarError = useCallback(() => setError(null), [])

  return (
    <AuthContext.Provider value={{
      usuario, cargando, error,
      modoMock: !FIREBASE_CONFIGURADO,
      login, logout,
      cambiarPwdPrimerLogin, cambiarPwd,
      isRole, puede, limpiarError,
    }}>
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth debe usarse dentro de AuthProvider')
  return ctx
}

"@ | Set-Content -Path "src\context\AuthContext.tsx" -Encoding UTF8

Write-Host "  src\hooks\useFirestore.ts" -ForegroundColor Gray
@"
import { useState, useEffect, useCallback } from 'react'
import { escucharPedidos } from '@services/pedidos.service'
import { escucharMaquinas } from '@services/maquinas.service'
import { FIREBASE_CONFIGURADO } from '@services/firebase'
import type { Pedido, Maquina } from '@/types'
import { useAuth } from '@context/AuthContext'

// ── Hook: Pedidos en tiempo real ──────────────────────────────
export const usePedidos = () => {
  const { usuario } = useAuth()
  const [pedidos,  setPedidos]  = useState<Pedido[]>([])
  const [cargando, setCargando] = useState(true)
  const [error,    setError]    = useState<string | null>(null)

  useEffect(() => {
    if (!usuario) return

    setCargando(true)
    setError(null)

    // Clientes solo ven sus pedidos
    const clienteUid = usuario.rol === 'cliente' ? usuario.uid : undefined

    try {
      const unsub = escucharPedidos(
        (data) => {
          setPedidos(data)
          setCargando(false)
        },
        clienteUid,
      )
      return () => unsub()
    } catch (e) {
      setError('Error al cargar pedidos')
      setCargando(false)
    }
  }, [usuario])

  return { pedidos, cargando, error, setPedidos }
}

// ── Hook: Máquinas en tiempo real ─────────────────────────────
export const useMaquinas = () => {
  const [maquinas, setMaquinas] = useState<Maquina[]>([])
  const [cargando, setCargando] = useState(true)

  useEffect(() => {
    const unsub = escucharMaquinas((data) => {
      setMaquinas(data)
      setCargando(false)
    })
    return () => unsub()
  }, [])

  return { maquinas, cargando }
}

// ── Hook: Estado de Firebase ──────────────────────────────────
export const useFirebaseStatus = () => ({
  configurado: FIREBASE_CONFIGURADO,
  modoMock:    !FIREBASE_CONFIGURADO,
})

"@ | Set-Content -Path "src\hooks\useFirestore.ts" -Encoding UTF8

Write-Host "  src\main.tsx" -ForegroundColor Gray
@"
import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import { AuthProvider } from '@context/AuthContext'
import App from './App'
import '@/styles/globals.css'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <BrowserRouter>
      <AuthProvider>
        <App />
      </AuthProvider>
    </BrowserRouter>
  </React.StrictMode>,
)

"@ | Set-Content -Path "src\main.tsx" -Encoding UTF8

Write-Host "  src\mock\mockData.ts" -ForegroundColor Gray
@"
import type { Pedido, Maquina, Usuario, Alerta } from '@/types'

// ── Usuarios mock ──────────────────────────────────────────────
export const MOCK_USUARIOS: Usuario[] = [
  {
    uid: 'admin-001', email: 'admin@imprenta.com',
    nombre: 'Administrador', rol: 'admin',
    activo: true, mustChangePassword: false,
    creadoEn: new Date('2026-01-01'),
  },
  {
    uid: 'op-001', email: 'operario@imprenta.com',
    nombre: 'Carlos Méndez', rol: 'operario',
    activo: true, mustChangePassword: false,
    creadoEn: new Date('2026-01-15'),
  },
  {
    uid: 'op-002', email: 'operario2@imprenta.com',
    nombre: 'Laura Ramos', rol: 'operario',
    activo: true, mustChangePassword: false,
    creadoEn: new Date('2026-02-01'),
  },
  {
    // Rol usuario: ve pedidos, producción (lectura), reportes, asigna máquinas
    uid: 'usr-001', email: 'usuario@imprenta.com',
    nombre: 'Martín Suárez', rol: 'usuario',
    activo: true, mustChangePassword: false,
    creadoEn: new Date('2026-02-15'),
  },
  {
    uid: 'cli-001', email: 'cliente@editorial.com',
    nombre: 'Editorial Sur S.A.', rol: 'cliente',
    activo: true, mustChangePassword: false,
    creadoEn: new Date('2026-01-20'),
  },
  // Usuario demo — backend simulado, para presentaciones
  {
    uid: 'demo-001', email: 'demo@imprenta.com',
    nombre: 'Usuario Demo', rol: 'admin',
    activo: true, mustChangePassword: false,
    creadoEn: new Date('2026-01-01'),
  },
]

// ── Máquinas mock ──────────────────────────────────────────────
export const MOCK_MAQUINAS: Maquina[] = [
  {
    id: 'maq-imp-01', nombre: 'Offset Heidelberg 01',
    tipo: 'impresion', capacidadDiaria: 5000,
    pedidosActivos: ['P-2026-0042', 'P-2026-0039'],
    activa: true, notas: 'Formato hasta 70×100cm',
  },
  {
    id: 'maq-imp-02', nombre: 'Digital Konica 02',
    tipo: 'impresion', capacidadDiaria: 2000,
    pedidosActivos: ['P-2026-0043'],
    activa: true, notas: 'Tiradas cortas, color',
  },
  {
    id: 'maq-enc-01', nombre: 'Guillotina + Lomo 01',
    tipo: 'encuadernacion', capacidadDiaria: 3000,
    pedidosActivos: ['P-2026-0041'],
    activa: true,
  },
  {
    id: 'maq-enc-02', nombre: 'Cosedora Fresadora 02',
    tipo: 'encuadernacion', capacidadDiaria: 1500,
    pedidosActivos: [], activa: true,
    notas: 'Para libros cosidos',
  },
]

// ── Pedidos mock (datos realistas para demo) ───────────────────
export const MOCK_PEDIDOS: Pedido[] = [
  // Pedido 1: En impresión, tiene Interior y Tapa con etapas registradas
  {
    id: 'P-2026-0042', numeroPedido: 'P-2026-0042',
    clienteUid: 'cli-001', clienteNombre: 'Editorial Sur S.A.',
    descripcion: 'Revista mensual N°48 — 200 páginas A4',
    claseProducto: 'revista',
    medidas: { altoMm: 297, anchoMm: 210 },
    cantidadOriginal: 2000, mermaProcentaje: 0.25, cantidadAjustada: 2005,
    tieneInteriorYTapa: true,
    maquinaInteriorId: 'maq-imp-01', maquinaInteriorNombre: 'Offset Heidelberg 01',
    subPedidos: [
      {
        id: 'P-2026-0042-I', pedidoId: 'P-2026-0042', tipo: 'interior',
        etapaActual: 'impresion',
        maquinaId: 'maq-imp-01', maquinaNombre: 'Offset Heidelberg 01',
        cantidad: 2005,
        etapas: [
          { id:'e1', nombre:'ingreso_pedido',
            fechaInicio: new Date('2026-04-24T08:00'), fechaFin: new Date('2026-04-24T09:00'),
            duracionMinutos:60, usuarioUid:'admin-001', usuarioNombre:'Administrador',
            alertaActiva:false, sinReferencia:true },
          { id:'e2', nombre:'preparado',
            fechaInicio: new Date('2026-04-24T09:00'), fechaFin: new Date('2026-04-24T14:00'),
            duracionMinutos:300, usuarioUid:'op-001', usuarioNombre:'Carlos Méndez',
            alertaActiva:false, sinReferencia:true },
          { id:'e3', nombre:'pre_produccion',
            fechaInicio: new Date('2026-04-24T14:00'), fechaFin: new Date('2026-04-24T16:30'),
            duracionMinutos:150, usuarioUid:'op-001', usuarioNombre:'Carlos Méndez',
            alertaActiva:false, sinReferencia:true },
          { id:'e4', nombre:'impresion',
            fechaInicio: new Date('2026-04-25T07:00'),
            maquinaId:'maq-imp-01', maquinaNombre:'Offset Heidelberg 01',
            usuarioUid:'op-001', usuarioNombre:'Carlos Méndez',
            alertaActiva:false, sinReferencia:true },
        ],
        fechaInicio: new Date('2026-04-24T08:00'), completado:false,
      },
      {
        id: 'P-2026-0042-T', pedidoId: 'P-2026-0042', tipo: 'tapa',
        etapaActual: 'pre_produccion', cantidad: 2005,
        etapas: [
          { id:'e5', nombre:'ingreso_pedido',
            fechaInicio: new Date('2026-04-24T08:00'), fechaFin: new Date('2026-04-24T09:00'),
            duracionMinutos:60, usuarioUid:'admin-001', usuarioNombre:'Administrador',
            alertaActiva:false, sinReferencia:true },
          { id:'e6', nombre:'preparado',
            fechaInicio: new Date('2026-04-24T09:00'), fechaFin: new Date('2026-04-24T13:00'),
            duracionMinutos:240, usuarioUid:'op-002', usuarioNombre:'Laura Ramos',
            alertaActiva:false, sinReferencia:true },
          { id:'e7', nombre:'pre_produccion',
            fechaInicio: new Date('2026-04-24T15:00'),
            usuarioUid:'op-002', usuarioNombre:'Laura Ramos',
            alertaActiva:false, sinReferencia:true },
        ],
        fechaInicio: new Date('2026-04-24T08:00'), completado:false,
      },
    ],
    estado: 'en_proceso', etapaActual: 'impresion',
    fechaIngreso: new Date('2026-04-24T08:00'),
    fechaEstimadaEntrega: new Date('2026-05-02T18:00'),
    creadoPor: 'admin-001', actualizadoEn: new Date('2026-04-29T16:00'),
    observaciones: 'Papel obra 90gr para interior',
  },

  // Pedido 2: En encuadernación — con alerta activa
  {
    id: 'P-2026-0041', numeroPedido: 'P-2026-0041',
    clienteUid: 'cli-002', clienteNombre: 'Librería Norma',
    descripcion: 'Catálogo temporada otoño — 48 páginas',
    claseProducto: 'catalogo',
    medidas: { altoMm: 210, anchoMm: 148 },
    cantidadOriginal: 500, mermaProcentaje: 0.20, cantidadAjustada: 501,
    tieneInteriorYTapa: true, subPedidos: [],
    estado: 'en_proceso', etapaActual: 'encuadernacion',
    fechaIngreso: new Date('2026-04-20T09:00'),
    fechaEstimadaEntrega: new Date('2026-04-30T18:00'),
    creadoPor: 'admin-001', actualizadoEn: new Date('2026-04-29T10:00'),
  },

  // Pedido 3: Entregado — muestra fecha real vs estimada
  {
    id: 'P-2026-0040', numeroPedido: 'P-2026-0040',
    clienteUid: 'cli-003', clienteNombre: 'Municipalidad de Palermo',
    descripcion: 'Folletos informativos — 4 páginas A5',
    claseProducto: 'folleto',
    medidas: { altoMm: 148, anchoMm: 105 },
    cantidadOriginal: 5000, mermaProcentaje: 0.20, cantidadAjustada: 5010,
    tieneInteriorYTapa: false, subPedidos: [],
    estado: 'entregado', etapaActual: 'entregado',
    fechaIngreso: new Date('2026-04-14T08:00'),
    fechaEstimadaEntrega: new Date('2026-04-25T18:00'),
    fechaRealEntrega: new Date('2026-04-25T14:30'),
    creadoPor: 'op-001', actualizadoEn: new Date('2026-04-25T14:30'),
  },

  // Pedido 4: Libro en impresión
  {
    id: 'P-2026-0039', numeroPedido: 'P-2026-0039',
    clienteUid: 'cli-001', clienteNombre: 'Editorial Sur S.A.',
    descripcion: 'Libro "Historia del Río" — 320 páginas',
    claseProducto: 'libro',
    medidas: { altoMm: 230, anchoMm: 155 },
    cantidadOriginal: 1000, mermaProcentaje: 0.30, cantidadAjustada: 1003,
    tieneInteriorYTapa: true,
    maquinaInteriorId: 'maq-imp-01', maquinaInteriorNombre: 'Offset Heidelberg 01',
    maquinaTapaId: 'maq-enc-02', maquinaTapaNombre: 'Cosedora Fresadora 02',
    subPedidos: [],
    estado: 'en_proceso', etapaActual: 'impresion',
    fechaIngreso: new Date('2026-04-22T10:00'),
    fechaEstimadaEntrega: new Date('2026-05-05T18:00'),
    creadoPor: 'admin-001', actualizadoEn: new Date('2026-04-28T11:00'),
    observaciones: 'Papel ilustración 115gr, tapa dura plastificado mate',
  },

  // Pedido 5: Recién ingresado
  {
    id: 'P-2026-0043', numeroPedido: 'P-2026-0043',
    clienteUid: 'cli-004', clienteNombre: 'Farmacia Central',
    descripcion: 'Recetarios personalizados — A5',
    claseProducto: 'otro',
    medidas: { altoMm: 148, anchoMm: 105 },
    cantidadOriginal: 300, mermaProcentaje: 0.20, cantidadAjustada: 301,
    tieneInteriorYTapa: false, subPedidos: [],
    estado: 'en_proceso', etapaActual: 'preparado',
    fechaIngreso: new Date('2026-04-29T09:00'),
    fechaEstimadaEntrega: new Date('2026-05-03T18:00'),
    creadoPor: 'op-002', actualizadoEn: new Date('2026-04-29T09:30'),
  },
]

// ── Alertas mock ───────────────────────────────────────────────
export const MOCK_ALERTAS: Alerta[] = [
  {
    id: 'alerta-001', pedidoId: 'P-2026-0041',
    numeroPedido: 'P-2026-0041', etapa: 'encuadernacion',
    tiempoRealMinutos: 580, tiempoPromedioMinutos: 420, factorSuperado: 1.38,
    creadaEn: new Date('2026-04-29T15:00'), resuelta: false,
  },
]

// ── Modo demo ──────────────────────────────────────────────────
export const MODO_DEMO = import.meta.env.VITE_APP_MODE === 'demo'
  || !import.meta.env.VITE_FIREBASE_API_KEY

export const MOCK_SESSION_DEMO = MOCK_USUARIOS.find(u => u.uid === 'demo-001')!

"@ | Set-Content -Path "src\mock\mockData.ts" -Encoding UTF8

Write-Host "  src\modules\auth\CambiarPasswordPage.tsx" -ForegroundColor Gray
@"
import React, { useState } from 'react'
import { Eye, EyeOff, AlertCircle, CheckCircle, Lock } from 'lucide-react'
import { useAuth } from '@context/AuthContext'

export default function CambiarPasswordPage() {
  const { cambiarPwdPrimerLogin, error, limpiarError, usuario } = useAuth()

  const [actual,     setActual]     = useState('')
  const [nueva,      setNueva]      = useState('')
  const [confirmar,  setConfirmar]  = useState('')
  const [showActual, setShowActual] = useState(false)
  const [showNueva,  setShowNueva]  = useState(false)
  const [guardando,  setGuardando]  = useState(false)
  const [listo,      setListo]      = useState(false)
  const [localErr,   setLocalErr]   = useState('')

  const validaciones = {
    longitud:    nueva.length >= 8,
    mayuscula:   /[A-Z]/.test(nueva),
    numero:      /[0-9]/.test(nueva),
    coincide:    nueva === confirmar && confirmar.length > 0,
  }
  const esValida = Object.values(validaciones).every(Boolean)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLocalErr('')
    limpiarError()

    if (!actual)   return setLocalErr('Ingresá tu contraseña actual')
    if (!esValida) return setLocalErr('La nueva contraseña no cumple los requisitos')

    setGuardando(true)
    try {
      await cambiarPwdPrimerLogin(actual, nueva)
      setListo(true)
    } catch {
      // el error queda en el contexto
    } finally {
      setGuardando(false)
    }
  }

  if (listo) {
    return (
      <div className="login-page">
        <div className="login-card" style={{ textAlign: 'center' }}>
          <CheckCircle size={48} color="var(--color-exito)" style={{ margin: '0 auto 16px' }} />
          <h2 style={{ fontSize: 20, fontWeight: 600, marginBottom: 8 }}>¡Contraseña actualizada!</h2>
          <p style={{ fontSize: 14, color: '#706C65', marginBottom: 24 }}>
            Tu contraseña fue cambiada exitosamente. Ahora podés usar el sistema.
          </p>
          <a href="/" className="btn btn-primary" style={{ justifyContent: 'center', width: '100%' }}>
            Ir al Dashboard
          </a>
        </div>
      </div>
    )
  }

  return (
    <div className="login-page">
      <div className="login-card">
        <div className="login-logo">
          <div style={{ display: 'flex', justifyContent: 'center', marginBottom: 10 }}>
            <div style={{
              width: 52, height: 52, borderRadius: 14,
              background: 'var(--color-tierra-50)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <Lock size={26} color="var(--color-tierra-600)" />
            </div>
          </div>
          <div className="login-logo-name">IMPRENTA</div>
          <div className="login-logo-sub">Cambio de contraseña requerido</div>
        </div>

        <div className="alert alert-info" style={{ marginBottom: 20 }}>
          <AlertCircle size={14} />
          <span style={{ fontSize: 13 }}>
            Hola <strong>{usuario?.nombre}</strong>, es tu primer ingreso.
            Por seguridad debés cambiar tu contraseña antes de continuar.
          </span>
        </div>

        {(localErr || error) && (
          <div className="alert alert-danger" style={{ marginBottom: 16 }}>
            <AlertCircle size={14} />
            <span>{localErr || error}</span>
          </div>
        )}

        <form onSubmit={handleSubmit} noValidate>
          {/* Contraseña actual */}
          <div className="form-group">
            <label className="form-label">Contraseña actual (temporal)</label>
            <div style={{ position: 'relative' }}>
              <input
                className="input"
                type={showActual ? 'text' : 'password'}
                value={actual}
                onChange={e => setActual(e.target.value)}
                placeholder="••••••••"
                style={{ paddingRight: 40 }}
              />
              <button type="button" onClick={() => setShowActual(v => !v)}
                style={{ position: 'absolute', right: 10, top: '50%', transform: 'translateY(-50%)', background: 'none', border: 'none', color: '#9C9890', cursor: 'pointer' }}>
                {showActual ? <EyeOff size={16} /> : <Eye size={16} />}
              </button>
            </div>
          </div>

          {/* Nueva contraseña */}
          <div className="form-group">
            <label className="form-label">Nueva contraseña</label>
            <div style={{ position: 'relative' }}>
              <input
                className="input"
                type={showNueva ? 'text' : 'password'}
                value={nueva}
                onChange={e => setNueva(e.target.value)}
                placeholder="Mínimo 8 caracteres"
                style={{ paddingRight: 40 }}
              />
              <button type="button" onClick={() => setShowNueva(v => !v)}
                style={{ position: 'absolute', right: 10, top: '50%', transform: 'translateY(-50%)', background: 'none', border: 'none', color: '#9C9890', cursor: 'pointer' }}>
                {showNueva ? <EyeOff size={16} /> : <Eye size={16} />}
              </button>
            </div>
            {/* Indicadores de validación */}
            {nueva.length > 0 && (
              <div style={{ marginTop: 8, display: 'flex', flexDirection: 'column', gap: 4 }}>
                {[
                  { ok: validaciones.longitud,  label: 'Mínimo 8 caracteres' },
                  { ok: validaciones.mayuscula, label: 'Al menos una mayúscula' },
                  { ok: validaciones.numero,    label: 'Al menos un número' },
                ].map(v => (
                  <div key={v.label} style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 12 }}>
                    <span style={{ color: v.ok ? 'var(--color-exito)' : '#C8C4BE' }}>{v.ok ? '✓' : '○'}</span>
                    <span style={{ color: v.ok ? 'var(--color-exito)' : '#9C9890' }}>{v.label}</span>
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Confirmar */}
          <div className="form-group">
            <label className="form-label">Confirmar nueva contraseña</label>
            <input
              className="input"
              type="password"
              value={confirmar}
              onChange={e => setConfirmar(e.target.value)}
              placeholder="Repetí la nueva contraseña"
              style={{
                borderColor: confirmar.length > 0
                  ? (validaciones.coincide ? 'var(--color-exito)' : 'var(--color-peligro)')
                  : undefined,
              }}
            />
            {confirmar.length > 0 && (
              <span style={{ fontSize: 12, color: validaciones.coincide ? 'var(--color-exito)' : 'var(--color-peligro)', marginTop: 4, display: 'block' }}>
                {validaciones.coincide ? '✓ Las contraseñas coinciden' : '✗ Las contraseñas no coinciden'}
              </span>
            )}
          </div>

          <button
            type="submit"
            className="btn btn-primary"
            disabled={guardando || !esValida || !actual}
            style={{ width: '100%', justifyContent: 'center', marginTop: 8, padding: '10px 0' }}
          >
            {guardando
              ? <><span className="spinner" style={{ width: 16, height: 16 }} /> Guardando...</>
              : 'Cambiar contraseña'}
          </button>
        </form>
      </div>
    </div>
  )
}

"@ | Set-Content -Path "src\modules\auth\CambiarPasswordPage.tsx" -Encoding UTF8

Write-Host "  src\modules\auth\LoginPage.tsx" -ForegroundColor Gray
@"
import React, { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { Lock, Printer, Eye, EyeOff, AlertCircle, ShieldCheck } from 'lucide-react'
import { useAuth } from '@context/AuthContext'

export default function LoginPage() {
  const { login, cargando, error } = useAuth()
  const navigate = useNavigate()

  const [email,    setEmail]    = useState('')
  const [password, setPassword] = useState('')
  const [showPwd,  setShowPwd]  = useState(false)
  const [localErr, setLocalErr] = useState('')

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLocalErr('')
    if (!email.trim()) return setLocalErr('Ingresa tu email')
    if (!password)     return setLocalErr('Ingresa tu contrasena')
    try {
      await login(email.trim(), password)
      navigate('/')
    } catch { /* error manejado por contexto */ }
  }

  const errMsg = localErr || error

  return (
    <div style={{
      minHeight: '100vh',
      background: 'linear-gradient(135deg, #0F172A 0%, #1E293B 50%, #0F172A 100%)',
      display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 24,
    }}>
      <div style={{ width: '100%', maxWidth: 420 }}>

        {/* Card principal */}
        <div style={{
          background: '#fff',
          border: '1px solid #E2E8F0',
          boxShadow: '0 25px 60px rgba(0,0,0,0.4)',
          padding: '48px 40px',
        }}>
          {/* Logo */}
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', marginBottom: 36 }}>
            <div style={{
              width: 64, height: 64,
              background: '#0F172A',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              marginBottom: 16,
            }}>
              <Printer size={30} color="white" />
            </div>
            <h1 style={{
              fontSize: 22, fontWeight: 700,
              letterSpacing: '0.12em', color: '#0F172A',
              textTransform: 'uppercase', margin: 0,
            }}>
              Imprenta Cloud
            </h1>
            <p style={{
              fontSize: 10, letterSpacing: '0.2em',
              color: '#94A3B8', marginTop: 6,
              textTransform: 'uppercase', fontWeight: 400,
            }}>
              Sistema de Gestión de Producción
            </p>
          </div>

          {/* Error */}
          {errMsg && (
            <div style={{
              display: 'flex', alignItems: 'flex-start', gap: 9,
              padding: '10px 13px', background: '#FEF2F2',
              border: '1px solid #FECACA', color: '#991B1B',
              fontSize: 13, marginBottom: 20,
            }}>
              <AlertCircle size={14} style={{ flexShrink: 0, marginTop: 1 }} />
              <span>{errMsg}</span>
            </div>
          )}

          {/* Form */}
          <form onSubmit={handleSubmit} noValidate>
            <div style={{ marginBottom: 24 }}>
              <label style={{
                display: 'block', fontSize: 10,
                letterSpacing: '0.15em', fontWeight: 700,
                color: '#64748B', textTransform: 'uppercase', marginBottom: 8,
              }}>
                Usuario / Email
              </label>
              <input
                type="email"
                value={email}
                onChange={e => setEmail(e.target.value)}
                placeholder="admin@imprenta.com"
                disabled={cargando}
                style={{
                  width: '100%', borderBottom: '2px solid #E2E8F0',
                  borderTop: 'none', borderLeft: 'none', borderRight: 'none',
                  padding: '10px 0', outline: 'none', background: 'transparent',
                  fontSize: 14, color: '#0F172A', fontFamily: 'inherit',
                  transition: 'border-color 150ms',
                }}
                onFocus={e => (e.target.style.borderBottomColor = '#0F172A')}
                onBlur={e  => (e.target.style.borderBottomColor = '#E2E8F0')}
                autoComplete="email"
              />
            </div>

            <div style={{ marginBottom: 32, position: 'relative' }}>
              <label style={{
                display: 'block', fontSize: 10,
                letterSpacing: '0.15em', fontWeight: 700,
                color: '#64748B', textTransform: 'uppercase', marginBottom: 8,
              }}>
                Contraseña
              </label>
              <input
                type={showPwd ? 'text' : 'password'}
                value={password}
                onChange={e => setPassword(e.target.value)}
                placeholder="••••••••"
                disabled={cargando}
                style={{
                  width: '100%', borderBottom: '2px solid #E2E8F0',
                  borderTop: 'none', borderLeft: 'none', borderRight: 'none',
                  padding: '10px 32px 10px 0', outline: 'none', background: 'transparent',
                  fontSize: 14, color: '#0F172A', fontFamily: 'inherit',
                  transition: 'border-color 150ms',
                }}
                onFocus={e => (e.target.style.borderBottomColor = '#0F172A')}
                onBlur={e  => (e.target.style.borderBottomColor = '#E2E8F0')}
                autoComplete="current-password"
              />
              <button
                type="button"
                onClick={() => setShowPwd(v => !v)}
                style={{
                  position: 'absolute', right: 0, bottom: 10,
                  background: 'none', border: 'none',
                  color: '#94A3B8', cursor: 'pointer', padding: 2,
                }}
              >
                {showPwd ? <EyeOff size={17} /> : <Eye size={17} />}
              </button>
            </div>

            <button
              type="submit"
              disabled={cargando}
              style={{
                width: '100%', background: cargando ? '#334155' : '#0F172A',
                color: 'white', border: 'none', padding: '14px 0',
                fontWeight: 700, fontSize: 11,
                letterSpacing: '0.2em', textTransform: 'uppercase',
                cursor: cargando ? 'not-allowed' : 'pointer',
                display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
                fontFamily: 'inherit', transition: 'background 150ms',
              }}
              onMouseEnter={e => { if (!cargando) (e.currentTarget.style.background = '#1E293B') }}
              onMouseLeave={e => { if (!cargando) (e.currentTarget.style.background = '#0F172A') }}
            >
              {cargando ? (
                <><span className="spinner" style={{ width: 16, height: 16, borderColor: '#475569', borderTopColor: '#94A3B8' }} /> Ingresando...</>
              ) : (
                <><Lock size={14} /> Ingresar al Sistema</>
              )}
            </button>

            <div style={{
              display: 'flex', justifyContent: 'space-between', alignItems: 'center',
              marginTop: 20, fontSize: 10, letterSpacing: '0.05em', color: '#94A3B8',
            }}>
              <a href="#" style={{ color: '#94A3B8', textDecoration: 'none', textTransform: 'uppercase' }}
                onMouseEnter={e => (e.currentTarget.style.color = '#0F172A')}
                onMouseLeave={e => (e.currentTarget.style.color = '#94A3B8')}>
                ¿Olvidó su contraseña?
              </a>
              <span>V2.0.0</span>
            </div>
          </form>
        </div>

        {/* Badge de seguridad */}
        <div style={{
          marginTop: 20, textAlign: 'center',
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 7,
        }}>
          <ShieldCheck size={14} color="#64748B" />
          <span style={{
            fontSize: 10, color: '#64748B',
            letterSpacing: '0.15em', textTransform: 'uppercase',
          }}>
            PBKDF2 · AES-256 Triple Capa · HMAC-SHA256
          </span>
        </div>

        {/* Hint demo */}
        <div style={{
          marginTop: 14, padding: '12px 16px',
          background: 'rgba(255,255,255,0.05)',
          border: '1px solid rgba(255,255,255,0.1)',
          fontSize: 12, color: '#94A3B8',
        }}>
          <strong style={{ color: '#CBD5E1', display: 'block', marginBottom: 5 }}>Modo demo</strong>
          Admin: <code style={{ color: '#94A3B8' }}>admin@imprenta.com</code><br/>
          Operario: <code style={{ color: '#94A3B8' }}>operario@imprenta.com</code><br/>
          Usuario: <code style={{ color: '#94A3B8' }}>usuario@imprenta.com</code><br/>
          Cliente: <code style={{ color: '#94A3B8' }}>cliente@editorial.com</code><br/>
          <span style={{ color: '#64748B', fontSize: 11 }}>Contraseña: cualquiera</span>
        </div>
      </div>
    </div>
  )
}

"@ | Set-Content -Path "src\modules\auth\LoginPage.tsx" -Encoding UTF8

Write-Host "  src\modules\configuracion\ConfiguracionPage.tsx" -ForegroundColor Gray
@"
import React, { useState } from 'react'
import { Save, Info } from 'lucide-react'
import { APP_CONFIG } from '@config/app.config'
import { ETAPAS } from '@config/etapas.config'
import type { AppConfig } from '@/types'

export default function ConfiguracionPage() {
  const [config, setConfig] = useState<AppConfig>({ ...APP_CONFIG })
  const [tab, setTab]       = useState<'general' | 'alertas' | 'merma' | 'etapas'>('general')
  const [guardado, setGuardado] = useState(false)

  const guardar = () => {
    // TODO: guardar en Firestore colección config/
    setGuardado(true)
    setTimeout(() => setGuardado(false), 2500)
  }

  const TABS = [
    { id: 'general', label: 'General' },
    { id: 'alertas', label: 'Alertas' },
    { id: 'merma',   label: 'Merma' },
    { id: 'etapas',  label: 'Etapas' },
  ] as const

  return (
    <div>
      <div className="page-header">
        <div>
          <h1 className="page-title">Configuración</h1>
          <p className="page-subtitle">Parámetros del sistema</p>
        </div>
        <button className="btn btn-primary" onClick={guardar}>
          <Save size={14} /> {guardado ? '✓ Guardado' : 'Guardar cambios'}
        </button>
      </div>

      {/* Tabs */}
      <div style={{ display: 'flex', gap: 4, marginBottom: 20, borderBottom: '1px solid #E0DDD8', paddingBottom: 0 }}>
        {TABS.map(t => (
          <button key={t.id}
            className={``btn btn-sm `${tab === t.id ? 'btn-primary' : 'btn-ghost'}``}
            style={{ borderRadius: '7px 7px 0 0', borderBottom: 'none' }}
            onClick={() => setTab(t.id)}>
            {t.label}
          </button>
        ))}
      </div>

      {/* General */}
      {tab === 'general' && (
        <div className="card" style={{ maxWidth: 520 }}>
          <h3 style={{ fontSize: 14, fontWeight: 600, marginBottom: 16 }}>Datos de la empresa</h3>
          <div className="form-group">
            <label className="form-label">Nombre de la empresa</label>
            <input className="input" value={config.nombreEmpresa}
              onChange={e => setConfig(c => ({ ...c, nombreEmpresa: e.target.value }))} />
          </div>
          <div className="form-group">
            <label className="form-label">Zona horaria</label>
            <select className="input" value={config.zonaHoraria}
              onChange={e => setConfig(c => ({ ...c, zonaHoraria: e.target.value }))}>
              <option value="America/Argentina/Buenos_Aires">Argentina (Buenos Aires)</option>
              <option value="America/Montevideo">Uruguay (Montevideo)</option>
              <option value="America/Santiago">Chile (Santiago)</option>
              <option value="America/Bogota">Colombia (Bogotá)</option>
            </select>
          </div>
        </div>
      )}

      {/* Alertas */}
      {tab === 'alertas' && (
        <div className="card" style={{ maxWidth: 520 }}>
          <h3 style={{ fontSize: 14, fontWeight: 600, marginBottom: 4 }}>Motor de alertas</h3>
          <p style={{ fontSize: 12, color: '#9C9890', marginBottom: 16 }}>
            Las alertas comparan el tiempo real de cada etapa con el promedio histórico de pedidos similares.
          </p>

          <div className="alert alert-info" style={{ marginBottom: 16 }}>
            <Info size={14} />
            <span style={{ fontSize: 12 }}>
              Las alertas solo se activan cuando hay al menos <strong>{config.alertas.muestrasMinimas} pedidos</strong> con características similares (mismo tipo, rango de tamaño y cantidad).
            </span>
          </div>

          <div className="form-group">
            <label className="form-label">
              Muestras mínimas para activar alertas
              <span style={{ fontSize: 11, color: '#9C9890', marginLeft: 6 }}>({config.alertas.muestrasMinimas} pedidos)</span>
            </label>
            <input className="input" type="range" min={3} max={20} step={1}
              value={config.alertas.muestrasMinimas}
              onChange={e => setConfig(c => ({ ...c, alertas: { ...c.alertas, muestrasMinimas: +e.target.value } }))}
              style={{ padding: 0, height: 6, accentColor: 'var(--color-tierra-500)' }} />
            <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 11, color: '#9C9890', marginTop: 2 }}>
              <span>3 (menos estricto)</span><span>20 (más estricto)</span>
            </div>
          </div>

          <div className="form-group">
            <label className="form-label">
              Factor de alerta
              <span style={{ fontSize: 11, color: '#9C9890', marginLeft: 6 }}>
                (alerta si tiempo real &gt; promedio × {config.alertas.factorAlerta})
              </span>
            </label>
            <input className="input" type="range" min={1.1} max={2.0} step={0.05}
              value={config.alertas.factorAlerta}
              onChange={e => setConfig(c => ({ ...c, alertas: { ...c.alertas, factorAlerta: +e.target.value } }))}
              style={{ padding: 0, height: 6, accentColor: 'var(--color-tierra-500)' }} />
            <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 11, color: '#9C9890', marginTop: 2 }}>
              <span>×1.1 (sensible)</span><span>×2.0 (tolerante)</span>
            </div>
          </div>

          <div className="form-group">
            <label style={{ display: 'flex', alignItems: 'center', gap: 9, cursor: 'pointer' }}>
              <input type="checkbox" checked={config.alertas.activado}
                onChange={e => setConfig(c => ({ ...c, alertas: { ...c.alertas, activado: e.target.checked } }))}
                style={{ width: 15, height: 15, accentColor: 'var(--color-tierra-500)' }} />
              <span className="form-label" style={{ margin: 0 }}>Alertas activadas</span>
            </label>
          </div>
        </div>
      )}

      {/* Merma */}
      {tab === 'merma' && (
        <div className="card" style={{ maxWidth: 520 }}>
          <h3 style={{ fontSize: 14, fontWeight: 600, marginBottom: 4 }}>Porcentaje de merma por tipo</h3>
          <p style={{ fontSize: 12, color: '#9C9890', marginBottom: 16 }}>
            Porcentaje predeterminado al crear un pedido. Puede ajustarse individualmente.
          </p>
          {(Object.keys(config.merma) as Array<keyof typeof config.merma>).map(tipo => (
            <div key={tipo} className="form-group">
              <label className="form-label" style={{ textTransform: 'capitalize' }}>
                {tipo} — {(config.merma[tipo]).toFixed(2)}%
              </label>
              <input className="input" type="range" min={0.05} max={5} step={0.05}
                value={config.merma[tipo]}
                onChange={e => setConfig(c => ({ ...c, merma: { ...c.merma, [tipo]: +e.target.value } }))}
                style={{ padding: 0, height: 6, accentColor: 'var(--color-tierra-500)' }} />
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 10, color: '#9C9890', marginTop: 1 }}>
                <span>0.05%</span><span>5%</span>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Etapas */}
      {tab === 'etapas' && (
        <div className="card">
          <h3 style={{ fontSize: 14, fontWeight: 600, marginBottom: 4 }}>Etapas del flujo de producción</h3>
          <p style={{ fontSize: 12, color: '#9C9890', marginBottom: 16 }}>
            Configuración de referencia. El orden y las propiedades se definen en <code style={{ fontSize: 11, background: '#F0EDE8', padding: '1px 5px', borderRadius: 4 }}>etapas.config.ts</code>.
          </p>
          <div className="table-wrapper">
            <table>
              <thead>
                <tr>
                  <th>Orden</th>
                  <th>Nombre interno</th>
                  <th>Label cliente</th>
                  <th>Req. máquina</th>
                  <th>Interior/Tapa</th>
                  <th>Ref. horas</th>
                </tr>
              </thead>
              <tbody>
                {ETAPAS.map(e => (
                  <tr key={e.nombre}>
                    <td style={{ fontSize: 13, fontWeight: 500, textAlign: 'center' }}>{e.orden}</td>
                    <td><span className={``badge `${e.badgeClass}``}>{e.label}</span></td>
                    <td style={{ fontSize: 12, color: '#706C65' }}>{e.labelCliente}</td>
                    <td style={{ textAlign: 'center' }}>{e.requiereMaquina ? '✓' : '—'}</td>
                    <td style={{ textAlign: 'center' }}>{e.esSubdividible ? '✓' : '—'}</td>
                    <td style={{ textAlign: 'center', fontSize: 12 }}>{e.tiempoRefHoras}h</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  )
}

"@ | Set-Content -Path "src\modules\configuracion\ConfiguracionPage.tsx" -Encoding UTF8

Write-Host "  src\modules\dashboard\DashboardPage.tsx" -ForegroundColor Gray
@"
import React from 'react'
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip,
  ResponsiveContainer, LineChart, Line, Legend,
} from 'recharts'
import {
  ClipboardList, Truck, AlertTriangle,
  CheckCircle, Clock, Printer,
} from 'lucide-react'
import KpiCard from './KpiCard'
import StatusBadge from '@components/StatusBadge'
import { usePedidos } from '@hooks/useFirestore'
import { MOCK_ALERTAS } from '@/mock/mockData'
import { fFecha, fFechaHora, progresoTiempo } from '@utils/fecha'
import { useAuth } from '@context/AuthContext'
import { ETAPAS } from '@config/etapas.config'

const DATA_SEMANA = [
  { dia: 'Lun', ingresados: 2, entregados: 1 },
  { dia: 'Mar', ingresados: 3, entregados: 2 },
  { dia: 'Mié', ingresados: 1, entregados: 3 },
  { dia: 'Jue', ingresados: 4, entregados: 1 },
  { dia: 'Vie', ingresados: 2, entregados: 4 },
  { dia: 'Sáb', ingresados: 1, entregados: 1 },
  { dia: 'Hoy', ingresados: 2, entregados: 0 },
]

export default function DashboardPage() {
  const { usuario } = useAuth()
  const { pedidos, cargando } = usePedidos()

  const pedidosActivos    = pedidos.filter(p => p.estado === 'en_proceso')
  const pedidosEntregados = pedidos.filter(p => p.estado === 'entregado')
  const alertasActivas    = MOCK_ALERTAS.filter(a => !a.resuelta)

  // Pedidos por etapa para el gráfico
  const dataEtapas = ETAPAS.slice(0, 6).map(e => ({
    etapa:    e.label.length > 10 ? e.label.slice(0, 10) + '…' : e.label,
    cantidad: pedidos.filter(p => p.etapaActual === e.nombre).length,
  }))

  if (cargando) {
    return (
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: 300, gap: 12, color: '#9C9890' }}>
        <span className="spinner" />
        <span>Cargando dashboard...</span>
      </div>
    )
  }

  return (
    <div>
      {/* Saludo */}
      <div className="page-header">
        <div>
          <h1 className="page-title">
            Bienvenido, {usuario?.nombre.split(' ')[0]}
          </h1>
          <p className="page-subtitle">
            {new Date().toLocaleDateString('es-AR', {
              weekday: 'long', year: 'numeric',
              month: 'long', day: 'numeric',
            })}
          </p>
        </div>
      </div>

      {/* KPIs */}
      <div className="kpi-grid">
        <KpiCard
          label="Pedidos activos"
          value={pedidosActivos.length}
          icon={ClipboardList}
          accent
          trend={{ valor: ```${pedidos.length} total``, tipo: 'neutral' }}
        />
        <KpiCard
          label="Entregados"
          value={pedidosEntregados.length}
          icon={Truck}
          iconColor="var(--color-exito)"
          trend={{ valor: pedidos.length > 0 ? ```${Math.round((pedidosEntregados.length / pedidos.length) * 100)}%`` : '0%', tipo: 'up', label: 'del total' }}
        />
        <KpiCard
          label="En impresión"
          value={pedidos.filter(p => p.etapaActual === 'impresion').length}
          icon={Printer}
          iconColor="var(--color-tierra-400)"
        />
        <KpiCard
          label="Alertas activas"
          value={alertasActivas.length}
          icon={AlertTriangle}
          iconColor={alertasActivas.length > 0 ? 'var(--color-alerta)' : 'var(--color-exito)'}
          trend={alertasActivas.length === 0
            ? { valor: 'Sin alertas', tipo: 'neutral' }
            : { valor: ```${alertasActivas.length} demorado(s)``, tipo: 'down' }}
        />
        <KpiCard
          label="Total pedidos"
          value={pedidos.length}
          icon={CheckCircle}
          iconColor="#9C9890"
        />
        <KpiCard
          label="Tiempo prom. ciclo"
          value="—"
          icon={Clock}
          iconColor="var(--color-info)"
          trend={{ valor: 'Disponible con 5+ pedidos', tipo: 'neutral' }}
        />
      </div>

      {/* Gráficos */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16, marginBottom: 24 }}>
        <div className="card">
          <h3 style={{ fontSize: 14, fontWeight: 600, marginBottom: 16 }}>
            Pedidos por etapa
          </h3>
          <ResponsiveContainer width="100%" height={200}>
            <BarChart data={dataEtapas} margin={{ top: 0, right: 0, left: -20, bottom: 0 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#F0EDE8" />
              <XAxis dataKey="etapa" tick={{ fontSize: 10, fill: '#9C9890' }} />
              <YAxis tick={{ fontSize: 11, fill: '#9C9890' }} allowDecimals={false} />
              <Tooltip contentStyle={{ fontSize: 12, border: '1px solid #E0DDD8', borderRadius: 8 }} />
              <Bar dataKey="cantidad" fill="var(--color-tierra-400)" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        <div className="card">
          <h3 style={{ fontSize: 14, fontWeight: 600, marginBottom: 16 }}>
            Última semana
          </h3>
          <ResponsiveContainer width="100%" height={200}>
            <LineChart data={DATA_SEMANA} margin={{ top: 0, right: 10, left: -20, bottom: 0 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#F0EDE8" />
              <XAxis dataKey="dia" tick={{ fontSize: 11, fill: '#9C9890' }} />
              <YAxis tick={{ fontSize: 11, fill: '#9C9890' }} allowDecimals={false} />
              <Tooltip contentStyle={{ fontSize: 12, border: '1px solid #E0DDD8', borderRadius: 8 }} />
              <Legend wrapperStyle={{ fontSize: 12 }} />
              <Line type="monotone" dataKey="ingresados" name="Ingresados"
                stroke="var(--color-tierra-500)" strokeWidth={2} dot={{ r: 3 }} />
              <Line type="monotone" dataKey="entregados" name="Entregados"
                stroke="var(--color-exito)" strokeWidth={2} dot={{ r: 3 }} />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Tabla pedidos activos + Alertas */}
      <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: 16 }}>
        <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
          <div style={{ padding: '14px 20px', borderBottom: '1px solid #F0EDE8' }}>
            <h3 style={{ fontSize: 14, fontWeight: 600 }}>Pedidos activos</h3>
          </div>
          {pedidosActivos.length === 0 ? (
            <div className="empty-state" style={{ padding: '32px 0' }}>
              <CheckCircle size={28} color="var(--color-exito)" style={{ opacity: 1, marginBottom: 8 }} />
              <p style={{ color: 'var(--color-exito)', fontSize: 13 }}>No hay pedidos activos</p>
            </div>
          ) : (
            <table>
              <thead>
                <tr>
                  <th>N° Pedido</th>
                  <th>Cliente</th>
                  <th>Etapa</th>
                  <th>Progreso</th>
                  <th>Entrega est.</th>
                </tr>
              </thead>
              <tbody>
                {pedidosActivos.map(p => {
                  const pct   = progresoTiempo(p.fechaIngreso, p.fechaEstimadaEntrega)
                  const clase = pct >= 100 ? 'danger' : pct >= 80 ? 'warning' : 'ok'
                  return (
                    <tr key={p.id}>
                      <td>
                        <span style={{ fontFamily: 'var(--font-mono)', fontSize: 12, color: 'var(--color-tierra-600)', fontWeight: 500 }}>
                          {p.numeroPedido}
                        </span>
                      </td>
                      <td style={{ maxWidth: 140 }}>
                        <span className="truncate" style={{ display: 'block', fontSize: 13 }}>
                          {p.clienteNombre}
                        </span>
                      </td>
                      <td><StatusBadge etapa={p.etapaActual} /></td>
                      <td style={{ minWidth: 100 }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: 7 }}>
                          <div className="progress-bar-wrap" style={{ flex: 1 }}>
                            <div className={``progress-bar-fill `${clase}``} style={{ width: ```${pct}%`` }} />
                          </div>
                          <span style={{ fontSize: 11, color: '#9C9890', whiteSpace: 'nowrap' }}>{pct}%</span>
                        </div>
                      </td>
                      <td style={{ fontSize: 12, color: '#706C65' }}>
                        {fFecha(p.fechaEstimadaEntrega)}
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          )}
        </div>

        {/* Panel alertas */}
        <div className="card">
          <h3 style={{ fontSize: 14, fontWeight: 600, marginBottom: 14 }}>Alertas activas</h3>
          {alertasActivas.length === 0 ? (
            <div className="empty-state" style={{ padding: '24px 0' }}>
              <CheckCircle size={28} color="var(--color-exito)"
                style={{ opacity: 1, marginBottom: 8 }} />
              <p style={{ color: 'var(--color-exito)', fontSize: 13 }}>Sin alertas activas</p>
            </div>
          ) : (
            alertasActivas.map(a => (
              <div key={a.id} className="alert alert-warning" style={{ marginBottom: 8 }}>
                <AlertTriangle size={14} style={{ flexShrink: 0, marginTop: 1 }} />
                <div>
                  <div style={{ fontWeight: 500, fontSize: 12 }}>{a.numeroPedido}</div>
                  <div style={{ fontSize: 11, marginTop: 2 }}>
                    <strong>{a.etapa}</strong> — {Math.round(a.tiempoRealMinutos / 60)}h reales
                    vs {Math.round(a.tiempoPromedioMinutos / 60)}h promedio
                  </div>
                  <div style={{ fontSize: 10, marginTop: 2, color: '#706C65' }}>
                    Factor ×{a.factorSuperado.toFixed(2)} · {fFechaHora(a.creadaEn)}
                  </div>
                </div>
              </div>
            ))
          )}
          <div style={{
            marginTop: 12, fontSize: 11, color: '#9C9890',
            borderTop: '1px solid #F0EDE8', paddingTop: 10,
          }}>
            Alertas activas cuando tiempo real &gt; promedio × 1.2
            (mín. 5 muestras comparables)
          </div>
        </div>
      </div>
    </div>
  )
}

"@ | Set-Content -Path "src\modules\dashboard\DashboardPage.tsx" -Encoding UTF8

Write-Host "  src\modules\dashboard\KpiCard.tsx" -ForegroundColor Gray
@"
import React from 'react'
import type { LucideIcon } from 'lucide-react'

interface Props {
  label: string
  value: string | number
  icon: LucideIcon
  iconColor?: string
  trend?: { valor: string; tipo: 'up' | 'down' | 'neutral'; label?: string }
  accent?: boolean
}

export default function KpiCard({ label, value, icon: Icon, iconColor, trend, accent }: Props) {
  return (
    <div className="kpi-card" style={accent ? { borderColor: 'var(--color-tierra-200)', borderLeftWidth: 3, borderLeftColor: 'var(--color-tierra-500)' } : {}}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 10 }}>
        <span className="kpi-label">{label}</span>
        <div style={{
          width: 32, height: 32, borderRadius: 8,
          background: 'var(--color-tierra-50)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          flexShrink: 0,
        }}>
          <Icon size={16} color={iconColor ?? 'var(--color-tierra-500)'} />
        </div>
      </div>
      <div className="kpi-value">{value}</div>
      {trend && (
        <div className={``kpi-trend `${trend.tipo}``}>
          <span>{trend.tipo === 'up' ? '↑' : trend.tipo === 'down' ? '↓' : '→'}</span>
          <span>{trend.valor}</span>
          {trend.label && <span style={{ color: '#9C9890', fontWeight: 400 }}>{trend.label}</span>}
        </div>
      )}
    </div>
  )
}

"@ | Set-Content -Path "src\modules\dashboard\KpiCard.tsx" -Encoding UTF8

Write-Host "  src\modules\pedidos\PedidoForm.tsx" -ForegroundColor Gray
@"
import React, { useState, useEffect } from 'react'
import { X, AlertCircle } from 'lucide-react'
import { useAuth } from '@context/AuthContext'
import { APP_CONFIG } from '@config/app.config'
import { generarNumeroPedido, calcularCantidadAjustada } from '@utils/pedido'
import type { Pedido, ClaseProducto } from '@/types'

interface Props {
  onClose:    () => void
  onGuardar:  (p: Omit<Pedido, 'id' | 'actualizadoEn' | 'subPedidos'>) => Promise<void>
  modoCliente?: boolean
}

const CLASES: { value: ClaseProducto; label: string }[] = [
  { value: 'libro',    label: 'Libro' },
  { value: 'revista',  label: 'Revista' },
  { value: 'folleto',  label: 'Folleto' },
  { value: 'catalogo', label: 'Catálogo' },
  { value: 'cuaderno', label: 'Cuaderno' },
  { value: 'otro',     label: 'Otro' },
]

export default function PedidoForm({ onClose, onGuardar, modoCliente = false }: Props) {
  const { usuario } = useAuth()
  const disabled = modoCliente

  const [clienteNombre,    setClienteNombre]    = useState('')
  const [descripcion,      setDescripcion]      = useState('')
  const [clase,            setClase]            = useState<ClaseProducto>('revista')
  const [altoMm,           setAltoMm]           = useState('')
  const [anchoMm,          setAnchoMm]          = useState('')
  const [cantidadOrig,     setCantidadOrig]     = useState('')
  const [mermaManual,      setMermaManual]      = useState('')
  const [tieneSubpedidos,  setTieneSubpedidos]  = useState(false)
  const [fechaEstimada,    setFechaEstimada]    = useState('')
  const [observaciones,    setObservaciones]    = useState('')
  const [errores,          setErrores]          = useState<Record<string, string>>({})
  const [guardando,        setGuardando]        = useState(false)

  const mermaDefault = APP_CONFIG.merma[clase] ?? 0.25
  const pctMerma     = mermaManual !== '' ? parseFloat(mermaManual) : mermaDefault * 100
  const cantNum      = parseInt(cantidadOrig) || 0
  const { ajustada } = calcularCantidadAjustada(cantNum, clase, pctMerma > 0 ? pctMerma : undefined)
  const unidadesMerma = ajustada - cantNum

  useEffect(() => { setMermaManual('') }, [clase])

  const validar = (): boolean => {
    const e: Record<string, string> = {}
    if (!clienteNombre.trim())                          e.clienteNombre  = 'Requerido'
    if (!descripcion.trim())                            e.descripcion    = 'Requerido'
    if (!altoMm  || isNaN(+altoMm)  || +altoMm  <= 0) e.altoMm         = 'Valor inválido'
    if (!anchoMm || isNaN(+anchoMm) || +anchoMm <= 0) e.anchoMm        = 'Valor inválido'
    if (!cantidadOrig || isNaN(+cantidadOrig) || +cantidadOrig <= 0) e.cantidad = 'Valor inválido'
    if (!fechaEstimada)                                 e.fechaEstimada  = 'Requerido'
    setErrores(e)
    return Object.keys(e).length === 0
  }

  const handleGuardar = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!validar()) return
    setGuardando(true)
    try {
      const numeroPedido = generarNumeroPedido()
      const nuevo: Omit<Pedido, 'id' | 'actualizadoEn' | 'subPedidos'> = {
        numeroPedido,
        clienteUid:           usuario?.uid ?? 'unknown',
        clienteNombre:        clienteNombre.trim(),
        descripcion:          descripcion.trim(),
        claseProducto:        clase,
        medidas:              { altoMm: +altoMm, anchoMm: +anchoMm },
        cantidadOriginal:     cantNum,
        mermaProcentaje:      pctMerma,
        cantidadAjustada:     ajustada,
        tieneInteriorYTapa:   tieneSubpedidos,
        estado:               'en_proceso',
        etapaActual:          'ingreso_pedido',
        fechaIngreso:         new Date(),
        fechaEstimadaEntrega: new Date(fechaEstimada),
        creadoPor:            usuario?.uid ?? 'unknown',
        observaciones:        observaciones.trim() || undefined,
      }
      await onGuardar(nuevo)
    } catch (err) {
      setErrores({ general: err instanceof Error ? err.message : 'Error al guardar' })
    } finally {
      setGuardando(false)
    }
  }

  return (
    <div className="modal-overlay" onClick={e => e.target === e.currentTarget && onClose()}>
      <div className="modal" style={{ maxWidth: 620 }}>
        <div className="modal-header">
          <h2 className="modal-title">
            {modoCliente ? '📋 Nuevo pedido (próximamente)' : 'Nuevo pedido'}
          </h2>
          <button className="btn btn-ghost btn-sm" onClick={onClose} style={{ padding: '4px 8px' }}>
            <X size={16} />
          </button>
        </div>

        {modoCliente && (
          <div className="alert alert-info" style={{ marginBottom: 16 }}>
            <AlertCircle size={14} />
            <span>El ingreso de pedidos desde el portal del cliente estará disponible próximamente.</span>
          </div>
        )}

        {errores.general && (
          <div className="alert alert-danger" style={{ marginBottom: 16 }}>
            <AlertCircle size={14} />
            <span>{errores.general}</span>
          </div>
        )}

        <form onSubmit={handleGuardar} noValidate>
          <div className="form-group">
            <label className="form-label">Cliente <span className="form-required">*</span></label>
            <input className="input" value={clienteNombre}
              onChange={e => setClienteNombre(e.target.value)}
              placeholder="Nombre del cliente o empresa" disabled={disabled} />
            {errores.clienteNombre && <span className="form-error">{errores.clienteNombre}</span>}
          </div>

          <div className="form-group">
            <label className="form-label">Descripción del trabajo <span className="form-required">*</span></label>
            <input className="input" value={descripcion}
              onChange={e => setDescripcion(e.target.value)}
              placeholder="Ej: Revista mensual N°48 — 200 páginas A4" disabled={disabled} />
            {errores.descripcion && <span className="form-error">{errores.descripcion}</span>}
          </div>

          <div className="form-group">
            <label className="form-label">Tipo de producto</label>
            <select className="input" value={clase}
              onChange={e => setClase(e.target.value as ClaseProducto)} disabled={disabled}>
              {CLASES.map(c => <option key={c.value} value={c.value}>{c.label}</option>)}
            </select>
          </div>

          <div className="form-row">
            <div className="form-group">
              <label className="form-label">Alto (mm) <span className="form-required">*</span></label>
              <input className="input" type="number" min="1" value={altoMm}
                onChange={e => setAltoMm(e.target.value)} placeholder="Ej: 297" disabled={disabled} />
              {errores.altoMm && <span className="form-error">{errores.altoMm}</span>}
            </div>
            <div className="form-group">
              <label className="form-label">Ancho (mm) <span className="form-required">*</span></label>
              <input className="input" type="number" min="1" value={anchoMm}
                onChange={e => setAnchoMm(e.target.value)} placeholder="Ej: 210" disabled={disabled} />
              {errores.anchoMm && <span className="form-error">{errores.anchoMm}</span>}
            </div>
          </div>

          <div className="form-row-3">
            <div className="form-group">
              <label className="form-label">Cantidad original <span className="form-required">*</span></label>
              <input className="input" type="number" min="1" value={cantidadOrig}
                onChange={e => setCantidadOrig(e.target.value)}
                placeholder="Ej: 2000" disabled={disabled} />
              {errores.cantidad && <span className="form-error">{errores.cantidad}</span>}
            </div>
            <div className="form-group">
              <label className="form-label">
                Merma %
                <span style={{ fontSize: 10, color: '#9C9890', marginLeft: 4 }}>
                  (def: {(mermaDefault * 100).toFixed(0)}%)
                </span>
              </label>
              <input className="input" type="number" min="0" max="20" step="0.1"
                value={mermaManual} onChange={e => setMermaManual(e.target.value)}
                placeholder={```${(mermaDefault * 100).toFixed(1)}``} disabled={disabled} />
            </div>
            <div className="form-group">
              <label className="form-label">Cantidad ajustada</label>
              <div className="input" style={{
                background: 'var(--color-tierra-25)', cursor: 'default',
                color: cantNum > 0 ? 'var(--color-tierra-700)' : '#9C9890',
                fontWeight: cantNum > 0 ? 500 : 400,
              }}>
                {cantNum > 0 ? ```${ajustada.toLocaleString()} (+`${unidadesMerma})`` : '—'}
              </div>
            </div>
          </div>

          <div className="form-group">
            <label style={{ display: 'flex', alignItems: 'center', gap: 9, cursor: 'pointer' }}>
              <input type="checkbox" checked={tieneSubpedidos}
                onChange={e => setTieneSubpedidos(e.target.checked)}
                disabled={disabled}
                style={{ width: 15, height: 15, accentColor: 'var(--color-tierra-500)' }} />
              <span className="form-label" style={{ margin: 0 }}>
                El pedido tiene <strong>Interior</strong> y <strong>Tapa</strong> independientes
              </span>
            </label>
            {tieneSubpedidos && (
              <div style={{
                marginTop: 8, padding: '8px 12px',
                background: 'var(--color-tierra-25)',
                borderRadius: 6, fontSize: 12, color: '#706C65',
              }}>
                Se generarán sub-pedidos:{' '}
                <strong style={{ color: '#4527A0' }}>-I</strong> (interior) y{' '}
                <strong style={{ color: 'var(--color-tierra-600)' }}>-T</strong> (tapa)
              </div>
            )}
          </div>

          <div className="form-group">
            <label className="form-label">
              Fecha estimada de entrega <span className="form-required">*</span>
            </label>
            <input className="input" type="date" value={fechaEstimada}
              onChange={e => setFechaEstimada(e.target.value)}
              min={new Date().toISOString().split('T')[0]} disabled={disabled} />
            {errores.fechaEstimada && <span className="form-error">{errores.fechaEstimada}</span>}
          </div>

          <div className="form-group">
            <label className="form-label">Observaciones</label>
            <textarea className="input" rows={3} value={observaciones}
              onChange={e => setObservaciones(e.target.value)}
              placeholder="Papel especial, acabado, instrucciones particulares..."
              disabled={disabled}
              style={{ resize: 'vertical', minHeight: 72 }} />
          </div>

          <div className="modal-footer">
            <button type="button" className="btn btn-ghost" onClick={onClose}>Cancelar</button>
            {!modoCliente && (
              <button type="submit" className="btn btn-primary" disabled={guardando}>
                {guardando
                  ? <><span className="spinner" style={{ width: 14, height: 14 }} /> Guardando...</>
                  : 'Crear pedido'}
              </button>
            )}
          </div>
        </form>
      </div>
    </div>
  )
}

"@ | Set-Content -Path "src\modules\pedidos\PedidoForm.tsx" -Encoding UTF8

Write-Host "  src\modules\pedidos\PedidosPage.tsx" -ForegroundColor Gray
@"
import React, { useState, useMemo } from 'react'
import { Plus, Search, X, Filter } from 'lucide-react'
import { useAuth } from '@context/AuthContext'
import { usePedidos } from '@hooks/useFirestore'
import StatusBadge from '@components/StatusBadge'
import PedidoForm from './PedidoForm'
import { crearPedido } from '@services/pedidos.service'
import { fFecha, progresoTiempo, estaVencido } from '@utils/fecha'
import { formatearMedidas } from '@utils/pedido'
import type { Pedido, EstadoPedido } from '@/types'

const ESTADOS: { value: EstadoPedido | ''; label: string }[] = [
  { value: '',           label: 'Todos los estados' },
  { value: 'en_proceso', label: 'En proceso' },
  { value: 'entregado',  label: 'Entregado' },
  { value: 'pausado',    label: 'Pausado' },
  { value: 'cancelado',  label: 'Cancelado' },
  { value: 'borrador',   label: 'Borrador' },
]

export default function PedidosPage() {
  const { isRole } = useAuth()
  const { pedidos, cargando, error } = usePedidos()

  const [showForm, setShowForm]       = useState(false)
  const [busqueda, setBusqueda]       = useState('')
  const [estado,   setEstado]         = useState<EstadoPedido | ''>('')
  const [cliente,  setCliente]        = useState('')
  const [fechaDesde, setFechaDesde]   = useState('')
  const [fechaHasta, setFechaHasta]   = useState('')

  const limpiarFiltros = () => {
    setBusqueda(''); setEstado(''); setCliente('')
    setFechaDesde(''); setFechaHasta('')
  }

  const hayFiltros = busqueda || estado || cliente || fechaDesde || fechaHasta

  const pedidosFiltrados = useMemo(() => {
    return pedidos.filter(p => {
      if (busqueda && !p.numeroPedido.toLowerCase().includes(busqueda.toLowerCase())
        && !p.descripcion.toLowerCase().includes(busqueda.toLowerCase())) return false
      if (estado  && p.estado !== estado) return false
      if (cliente && !p.clienteNombre.toLowerCase().includes(cliente.toLowerCase())) return false
      if (fechaDesde && p.fechaIngreso < new Date(fechaDesde)) return false
      if (fechaHasta && p.fechaIngreso > new Date(fechaHasta + 'T23:59:59')) return false
      return true
    })
  }, [pedidos, busqueda, estado, cliente, fechaDesde, fechaHasta])

  const handleNuevoPedido = async (nuevo: Omit<Pedido, 'id' | 'actualizadoEn' | 'subPedidos'>) => {
    await crearPedido(nuevo)
    setShowForm(false)
    // usePedidos escucha en tiempo real: la lista se actualiza sola
  }

  if (cargando) {
    return (
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: 300, gap: 12, color: '#9C9890' }}>
        <span className="spinner" />
        <span>Cargando pedidos...</span>
      </div>
    )
  }

  if (error) {
    return (
      <div className="alert alert-danger" style={{ maxWidth: 500 }}>
        <span>{error}</span>
      </div>
    )
  }

  return (
    <div>
      <div className="page-header">
        <div>
          <h1 className="page-title">Pedidos</h1>
          <p className="page-subtitle">
            {pedidosFiltrados.length} de {pedidos.length} pedidos
          </p>
        </div>
        {isRole('admin', 'operario') && (
          <button className="btn btn-primary" onClick={() => setShowForm(true)}>
            <Plus size={15} /> Nuevo pedido
          </button>
        )}
      </div>

      {/* Filtros */}
      <div className="filtros-bar">
        <div style={{ position: 'relative', flex: '1 1 180px', minWidth: 160 }}>
          <Search size={14} style={{ position: 'absolute', left: 10, top: '50%', transform: 'translateY(-50%)', color: '#9C9890' }} />
          <input className="input" style={{ paddingLeft: 30 }}
            placeholder="N° pedido o descripción..."
            value={busqueda} onChange={e => setBusqueda(e.target.value)} />
        </div>
        <div style={{ flex: '1 1 160px', minWidth: 140 }}>
          <input className="input" placeholder="Cliente..."
            value={cliente} onChange={e => setCliente(e.target.value)} />
        </div>
        <select className="input" style={{ flex: '0 0 160px' }}
          value={estado} onChange={e => setEstado(e.target.value as EstadoPedido | '')}>
          {ESTADOS.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
        </select>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          <span style={{ fontSize: 12, color: '#9C9890', whiteSpace: 'nowrap' }}>Ingreso:</span>
          <input type="date" className="input" style={{ width: 138 }}
            value={fechaDesde} onChange={e => setFechaDesde(e.target.value)} />
          <span style={{ fontSize: 12, color: '#9C9890' }}>—</span>
          <input type="date" className="input" style={{ width: 138 }}
            value={fechaHasta} onChange={e => setFechaHasta(e.target.value)} />
        </div>
        {hayFiltros && (
          <button className="btn btn-ghost btn-sm" onClick={limpiarFiltros}>
            <X size={13} /> Limpiar
          </button>
        )}
      </div>

      {/* Tabla */}
      <div className="table-wrapper">
        {pedidosFiltrados.length === 0 ? (
          <div className="empty-state">
            <Filter size={32} />
            <p>No hay pedidos que coincidan con los filtros</p>
          </div>
        ) : (
          <table>
            <thead>
              <tr>
                <th>N° Pedido</th>
                <th>Cliente</th>
                <th>Descripción</th>
                <th>Medidas</th>
                <th>Cantidad</th>
                <th>Estado</th>
                <th>Etapa actual</th>
                <th>Ingreso</th>
                <th>Est. entrega</th>
                <th>Real entrega</th>
                <th>Progreso</th>
              </tr>
            </thead>
            <tbody>
              {pedidosFiltrados.map(p => {
                const pct     = progresoTiempo(p.fechaIngreso, p.fechaEstimadaEntrega)
                const clase   = pct >= 100 ? 'danger' : pct >= 80 ? 'warning' : 'ok'
                const vencido = estaVencido(p.fechaEstimadaEntrega) && p.estado !== 'entregado'
                return (
                  <tr key={p.id}>
                    <td>
                      <span style={{ fontFamily: 'var(--font-mono)', fontSize: 12, color: 'var(--color-tierra-600)', fontWeight: 500 }}>
                        {p.numeroPedido}
                      </span>
                      {p.tieneInteriorYTapa && (
                        <div style={{ display: 'flex', gap: 3, marginTop: 3 }}>
                          <span style={{ fontSize: 10, background: '#EDE7F6', color: '#4527A0', padding: '1px 5px', borderRadius: 3 }}>-I</span>
                          <span style={{ fontSize: 10, background: 'var(--color-tierra-50)', color: 'var(--color-tierra-700)', padding: '1px 5px', borderRadius: 3 }}>-T</span>
                        </div>
                      )}
                    </td>
                    <td style={{ fontSize: 13, maxWidth: 130 }}>
                      <span className="truncate" style={{ display: 'block' }}>{p.clienteNombre}</span>
                    </td>
                    <td style={{ fontSize: 12, color: '#706C65', maxWidth: 160 }}>
                      <span className="truncate" style={{ display: 'block' }}>{p.descripcion}</span>
                    </td>
                    <td style={{ fontSize: 12, color: '#706C65', whiteSpace: 'nowrap' }}>
                      {formatearMedidas(p.medidas.altoMm, p.medidas.anchoMm)}
                    </td>
                    <td style={{ fontSize: 12, textAlign: 'right' }}>
                      <div>{p.cantidadOriginal.toLocaleString()}</div>
                      <div style={{ fontSize: 10, color: '#9C9890' }}>+{p.cantidadAjustada - p.cantidadOriginal} merma</div>
                    </td>
                    <td><StatusBadge estado={p.estado} /></td>
                    <td><StatusBadge etapa={p.etapaActual} /></td>
                    <td style={{ fontSize: 12, color: '#706C65', whiteSpace: 'nowrap' }}>{fFecha(p.fechaIngreso)}</td>
                    <td style={{ fontSize: 12, whiteSpace: 'nowrap', color: vencido ? 'var(--color-peligro)' : '#706C65', fontWeight: vencido ? 500 : 400 }}>
                      {fFecha(p.fechaEstimadaEntrega)}
                      {vencido && <span style={{ fontSize: 10, display: 'block' }}>⚑ Vencido</span>}
                    </td>
                    <td style={{ fontSize: 12, color: p.fechaRealEntrega ? 'var(--color-exito)' : '#9C9890', whiteSpace: 'nowrap' }}>
                      {p.fechaRealEntrega ? fFecha(p.fechaRealEntrega) : '—'}
                    </td>
                    <td style={{ minWidth: 90 }}>
                      {p.estado !== 'entregado' ? (
                        <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                          <div className="progress-bar-wrap" style={{ flex: 1 }}>
                            <div className={``progress-bar-fill `${clase}``} style={{ width: ```${pct}%`` }} />
                          </div>
                          <span style={{ fontSize: 11, color: '#9C9890' }}>{pct}%</span>
                        </div>
                      ) : (
                        <span style={{ fontSize: 12, color: 'var(--color-exito)' }}>✓ Completo</span>
                      )}
                    </td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        )}
      </div>

      {showForm && (
        <PedidoForm
          onClose={() => setShowForm(false)}
          onGuardar={handleNuevoPedido}
        />
      )}
    </div>
  )
}

"@ | Set-Content -Path "src\modules\pedidos\PedidosPage.tsx" -Encoding UTF8

Write-Host "  src\modules\produccion\EtapaTimeline.tsx" -ForegroundColor Gray
@"
import React, { useState } from 'react'
import { CheckCircle, Clock, ChevronRight, Wrench, XCircle } from 'lucide-react'
import type { Pedido, SubPedido, NombreEtapa } from '@/types'
import { ETAPAS, getEtapa, getSiguienteEtapa } from '@config/etapas.config'
import { fFechaHora, diffHorasTexto, diffMinutos } from '@utils/fecha'
import { puedeAvanzarDesde } from '@utils/etapaValidacion'
import StatusBadge from '@components/StatusBadge'

interface Props {
  pedido:          Pedido
  onAvanzarEtapa?: (pedidoId: string, subId: string | null, etapa: NombreEtapa) => void
  soloLectura?:    boolean
}

export default function EtapaTimeline({ pedido, onAvanzarEtapa, soloLectura = false }: Props) {
  const [tabActivo,   setTabActivo]   = useState<'interior'|'tapa'>('interior')
  const [confirmando, setConfirmando] = useState<string|null>(null)
  const [errorLocal,  setErrorLocal]  = useState<string|null>(null)

  const tieneSubpedidos = pedido.tieneInteriorYTapa && pedido.subPedidos.length > 0
  const subInterior     = pedido.subPedidos.find(s => s.tipo === 'interior')
  const subTapa         = pedido.subPedidos.find(s => s.tipo === 'tapa')

  const handleIntentarAvanzar = (etapaActual: NombreEtapa, sub: SubPedido | null) => {
    setErrorLocal(null)
    const etapasReg = sub ? sub.etapas : []
    const maquinaId = sub ? sub.maquinaId : pedido.maquinaInteriorId
    const validacion = puedeAvanzarDesde(etapaActual, etapasReg, maquinaId)
    if (!validacion.valido) {
      setErrorLocal(validacion.detalle ?? validacion.mensaje)
      return
    }
    setConfirmando(etapaActual)
  }

  const handleConfirmar = (etapaActual: NombreEtapa, sub: SubPedido | null) => {
    const siguiente = getSiguienteEtapa(etapaActual)
    if (!siguiente || !onAvanzarEtapa) return
    onAvanzarEtapa(pedido.id, sub?.id ?? null, siguiente)
    setConfirmando(null); setErrorLocal(null)
  }

  const renderItem = (
    nombre:       NombreEtapa,
    fechaInicio?: Date,
    fechaFin?:    Date,
    duracion?:    number,
    responsable?: string,
    maquina?:     string,
    alerta?:      boolean,
    sinRef?:      boolean,
    esCurrent?:   boolean,
    sub:          SubPedido | null = null,
  ) => {
    const cfg            = getEtapa(nombre)
    const completado     = !!fechaFin
    const enCurso        = !!fechaInicio && !fechaFin
    const siguiente      = getSiguienteEtapa(nombre)
    const estaConf       = confirmando === nombre
    const validacion     = (!soloLectura && esCurrent && siguiente)
      ? puedeAvanzarDesde(nombre, sub?.etapas ?? [], sub?.maquinaId)
      : null

    return (
      <div key={nombre} style={{ position:'relative', marginBottom:18, paddingLeft:26 }}>
        {/* Dot */}
        <div style={{
          position:'absolute', left:0, top:4,
          width:14, height:14, borderRadius:'50%',
          border:'2px solid #fff',
          boxShadow: alerta ? '0 0 0 1px var(--color-alerta)'
            : completado   ? '0 0 0 1px var(--exito)'
            : esCurrent    ? '0 0 0 1px var(--t400)'
            : '0 0 0 1px var(--g200)',
          background: alerta ? 'var(--alerta)'
            : completado   ? 'var(--exito)'
            : esCurrent    ? 'var(--t400)'
            : 'var(--g200)',
        }}/>

        {/* Caja */}
        <div style={{
          background:'#fff',
          border:``1px solid `${esCurrent ? 'var(--t300)' : 'var(--g200)'}``,
          borderRadius:8, padding:'11px 13px',
          boxShadow: esCurrent ? '0 0 0 2px rgba(196,154,108,.2)' : 'none',
        }}>
          {/* Header */}
          <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', flexWrap:'wrap', gap:7, marginBottom:5 }}>
            <div style={{ display:'flex', alignItems:'center', gap:8, flexWrap:'wrap' }}>
              <span style={{ fontSize:13, fontWeight:500, color:'var(--g700)' }}>{cfg.label}</span>
              {esCurrent && <span style={{ fontSize:10, background:'var(--t100)', color:'var(--t800)', padding:'1px 7px', borderRadius:999, fontWeight:500 }}>EN CURSO</span>}
              {alerta    && <span style={{ fontSize:10, background:'var(--alertal)', color:'var(--alertad)', padding:'1px 7px', borderRadius:999 }}>⚑ ALERTA</span>}
              {sinRef && !completado && <span style={{ fontSize:10, background:'var(--g100)', color:'var(--g500)', padding:'1px 7px', borderRadius:999 }}>sin referencia</span>}
            </div>
            <StatusBadge etapa={nombre}/>
          </div>

          {/* Fechas */}
          <div style={{ fontSize:11, color:'var(--g400)', display:'flex', flexDirection:'column', gap:2 }}>
            {fechaInicio ? <span>Inicio: {fFechaHora(fechaInicio)}</span> : <span style={{ color:'var(--g200)' }}>Pendiente</span>}
            {fechaFin    && <span>Fin: {fFechaHora(fechaFin)}</span>}
            {enCurso     && <span style={{ color:'var(--t500)' }}>En curso — {diffHorasTexto(diffMinutos(fechaInicio!))} transcurridos</span>}
          </div>

          {/* Meta */}
          {(responsable||maquina||duracion) && (
            <div style={{ fontSize:11, color:'var(--g500)', display:'flex', gap:12, flexWrap:'wrap', marginTop:4 }}>
              {responsable && <span>👤 {responsable}</span>}
              {maquina     && <span><Wrench size={11} style={{ display:'inline', verticalAlign:'middle' }}/> {maquina}</span>}
              {duracion    && <span><Clock  size={11} style={{ display:'inline', verticalAlign:'middle' }}/> {diffHorasTexto(duracion)}</span>}
            </div>
          )}

          {/* Zona avance */}
          {!soloLectura && esCurrent && siguiente && onAvanzarEtapa && (
            <div style={{ marginTop:11 }}>
              {/* Error de validación */}
              {errorLocal && !estaConf && (
                <div style={{
                  display:'flex', alignItems:'flex-start', gap:8,
                  padding:'8px 11px', background:'var(--peligrol)',
                  border:'1px solid var(--peligro)', borderRadius:7,
                  fontSize:12, color:'var(--peligrod)', marginBottom:10,
                }}>
                  <XCircle size={14} style={{ flexShrink:0, marginTop:1 }}/>
                  <span>{errorLocal}</span>
                </div>
              )}

              {estaConf ? (
                <div style={{
                  padding:'10px 12px',
                  background:'var(--t25)', border:'1px solid var(--t200)', borderRadius:8,
                }}>
                  <p style={{ fontSize:12, color:'var(--t700)', marginBottom:4, fontWeight:500 }}>
                    ¿Confirmar avance a <strong>{getEtapa(siguiente).label}</strong>?
                  </p>
                  <p style={{ fontSize:11, color:'var(--g500)', marginBottom:10 }}>
                    Se registrará la fecha de fin de "{cfg.label}" con la hora actual.
                  </p>
                  <div style={{ display:'flex', gap:8 }}>
                    <button className="btn btn-primary btn-sm"
                      onClick={() => handleConfirmar(nombre, sub)}>
                      <CheckCircle size={13}/> Confirmar
                    </button>
                    <button className="btn btn-ghost btn-sm"
                      onClick={() => { setConfirmando(null); setErrorLocal(null) }}>
                      Cancelar
                    </button>
                  </div>
                </div>
              ) : (
                <button
                  className={``btn btn-sm `${validacion?.valido===false ? 'btn-ghost' : 'btn-secondary'}``}
                  style={{ opacity: validacion?.valido===false ? 0.55 : 1 }}
                  onClick={() => handleIntentarAvanzar(nombre, sub)}
                  title={validacion?.valido===false ? validacion.detalle : undefined}
                >
                  {validacion?.valido===false
                    ? <><XCircle size={13}/> No se puede avanzar</>
                    : <>Avanzar a {getEtapa(siguiente).label} <ChevronRight size={13}/></>}
                </button>
              )}
            </div>
          )}
        </div>
      </div>
    )
  }

  const renderSub = (sub: SubPedido|undefined, tipo: 'interior'|'tapa') => {
    if (!sub) return <div className="empty-state" style={{ padding:'24px 0' }}><p>Sub-pedido {tipo} no encontrado</p></div>
    return (
      <div>
        <div style={{ display:'flex', gap:12, marginBottom:14, flexWrap:'wrap' }}>
          <div className="card-surface" style={{ flex:'0 0 auto' }}>
            <span style={{ fontSize:11, color:'var(--g400)' }}>ID</span>
            <div style={{ fontSize:13, fontWeight:500, fontFamily:'var(--font-mono)', color: tipo==='interior'?'#4527A0':'var(--t600)' }}>{sub.id}</div>
          </div>
          {sub.maquinaNombre && (
            <div className="card-surface" style={{ flex:'0 0 auto' }}>
              <span style={{ fontSize:11, color:'var(--g400)' }}>Máquina</span>
              <div style={{ fontSize:13, fontWeight:500 }}>{sub.maquinaNombre}</div>
            </div>
          )}
          <div className="card-surface" style={{ flex:'0 0 auto' }}>
            <span style={{ fontSize:11, color:'var(--g400)' }}>Etapa actual</span>
            <div style={{ marginTop:3 }}><StatusBadge etapa={sub.etapaActual}/></div>
          </div>
        </div>
        <div style={{ position:'relative', paddingLeft:28 }}>
          <div style={{ position:'absolute', left:8, top:0, bottom:0, width:1, background:'linear-gradient(to bottom,var(--t200),transparent)' }}/>
          {ETAPAS.map(cfg => {
            const reg = sub.etapas.find(e => e.nombre === cfg.nombre)
            const esCurrent = sub.etapaActual === cfg.nombre && !sub.completado
            const etapaOrd  = getEtapa(sub.etapaActual).orden
            if (!reg && !esCurrent && cfg.orden > etapaOrd+2) return null
            return renderItem(cfg.nombre, reg?.fechaInicio, reg?.fechaFin, reg?.duracionMinutos, reg?.usuarioNombre, reg?.maquinaNombre, reg?.alertaActiva, reg?.sinReferencia, esCurrent, sub)
          })}
        </div>
      </div>
    )
  }

  const renderSimple = () => (
    <div style={{ position:'relative', paddingLeft:28 }}>
      <div style={{ position:'absolute', left:8, top:0, bottom:0, width:1, background:'linear-gradient(to bottom,var(--t200),transparent)' }}/>
      {ETAPAS.map(cfg => {
        const esCurrent = pedido.etapaActual===cfg.nombre && pedido.estado!=='entregado'
        const yaFue     = getEtapa(pedido.etapaActual).orden > cfg.orden
        if (!yaFue && !esCurrent && cfg.orden > getEtapa(pedido.etapaActual).orden+2) return null
        return renderItem(cfg.nombre, yaFue||esCurrent?pedido.fechaIngreso:undefined, yaFue?new Date():undefined, undefined, undefined, undefined, false, true, esCurrent, null)
      })}
    </div>
  )

  return (
    <div>
      {tieneSubpedidos && (
        <div className="subpedido-tabs">
          <button className={``subpedido-tab `${tabActivo==='interior'?'active-interior':''}``}
            onClick={() => { setTabActivo('interior'); setErrorLocal(null); setConfirmando(null) }}>
            Interior {subInterior && <StatusBadge etapa={subInterior.etapaActual}/>}
          </button>
          <button className={``subpedido-tab `${tabActivo==='tapa'?'active-tapa':''}``}
            onClick={() => { setTabActivo('tapa'); setErrorLocal(null); setConfirmando(null) }}>
            Tapa {subTapa && <StatusBadge etapa={subTapa.etapaActual}/>}
          </button>
        </div>
      )}
      {tieneSubpedidos
        ? renderSub(tabActivo==='interior' ? subInterior : subTapa, tabActivo)
        : renderSimple()}
    </div>
  )
}

"@ | Set-Content -Path "src\modules\produccion\EtapaTimeline.tsx" -Encoding UTF8

Write-Host "  src\modules\produccion\ProduccionPage.tsx" -ForegroundColor Gray
@"
import React, { useState } from 'react'
import { ChevronDown, ChevronUp, ArrowRight, Settings2, Printer } from 'lucide-react'
import { useAuth } from '@context/AuthContext'
import { usePedidos, useMaquinas } from '@hooks/useFirestore'
import { avanzarEtapaPedido, actualizarPedido } from '@services/pedidos.service'
import EtapaTimeline from './EtapaTimeline'
import StatusBadge from '@components/StatusBadge'
import MaquinaSelector from '@components/MaquinaSelector'
import { fFecha, progresoTiempo } from '@utils/fecha'
import { formatearMedidas } from '@utils/pedido'
import { ETAPAS, getEtapa } from '@config/etapas.config'
import type { NombreEtapa, Pedido } from '@/types'

const ETAPAS_LABELS = ETAPAS.map(e => e.label)

export default function ProduccionPage() {
  const { usuario, puede, isRole }          = useAuth()
  const { pedidos, cargando }               = usePedidos()
  const { maquinas }                        = useMaquinas()
  const [expandido, setExpandido]           = useState<string | null>(null)
  const [filtroEstado, setFiltroEstado]     = useState<'activos' | 'todos'>('activos')
  const [avanzando, setAvanzando]           = useState<string | null>(null)
  const [showMaqModal, setShowMaqModal]     = useState<{pedidoId:string,tipo:'interior'|'tapa'} | null>(null)

  const pedidosMostrar = filtroEstado === 'activos'
    ? pedidos.filter(p => p.estado === 'en_proceso' || p.estado === 'pausado')
    : pedidos

  const toggle = (id: string) =>
    setExpandido(prev => prev === id ? null : id)

  const handleAvanzarEtapa = async (
    pedidoId: string,
    _subId:   string | null,
    siguienteEtapa: NombreEtapa,
  ) => {
    if (!usuario || !puede('avanzarEtapas')) return
    setAvanzando(pedidoId)
    try {
      await avanzarEtapaPedido(pedidoId, siguienteEtapa, usuario.uid, usuario.nombre)
    } catch (e) { console.error('Error al avanzar etapa:', e) }
    finally { setAvanzando(null) }
  }

  const handleAsignarMaquina = async (
    pedidoId: string,
    tipo: 'interior' | 'tapa',
    maquinaId: string,
    maquinaNombre: string,
  ) => {
    const campo = tipo === 'interior'
      ? { maquinaInteriorId: maquinaId, maquinaInteriorNombre: maquinaNombre }
      : { maquinaTapaId: maquinaId, maquinaTapaNombre: maquinaNombre }
    await actualizarPedido(pedidoId, campo)
    setShowMaqModal(null)
  }

  if (cargando) return (
    <div style={{ display:'flex', alignItems:'center', justifyContent:'center', height:300, gap:12, color:'#706C65' }}>
      <span className="spinner"/><span>Cargando producción...</span>
    </div>
  )

  return (
    <div>
      <div className="page-header">
        <div>
          <h1 className="page-title">Flujo de Producción</h1>
          <p className="page-sub">Monitoreo de etapas y control de sub-productos</p>
        </div>
        <div style={{ display:'flex', gap:8 }}>
          <button className={``btn `${filtroEstado==='activos'?'btn-primary':'btn-ghost'} btn-sm``}
            onClick={() => setFiltroEstado('activos')}>
            Activos ({pedidos.filter(p=>p.estado==='en_proceso').length})
          </button>
          <button className={``btn `${filtroEstado==='todos'?'btn-primary':'btn-ghost'} btn-sm``}
            onClick={() => setFiltroEstado('todos')}>
            Todos ({pedidos.length})
          </button>
        </div>
      </div>

      {/* Barra de etapas — visual estilo slate del proyecto de referencia */}
      <div style={{
        display:'grid', gridTemplateColumns:``repeat(`${ETAPAS_LABELS.length},1fr)``,
        gap:3, marginBottom:20,
        background:'#fff', border:'1px solid var(--g200)', borderRadius:10, padding:'12px 16px',
      }}>
        {ETAPAS.map((e, i) => {
          const activos = pedidos.filter(p => p.etapaActual === e.nombre && p.estado === 'en_proceso').length
          return (
            <div key={e.nombre} style={{ display:'flex', flexDirection:'column', alignItems:'center', gap:5 }}>
              <div style={{
                width:'100%', height:4, borderRadius:2,
                background: activos > 0 ? 'var(--t500)' : i === 0 ? 'var(--exito)' : 'var(--g100)',
              }}/>
              <span style={{ fontSize:9, fontWeight:600, letterSpacing:'0.05em', color:'var(--g400)', textTransform:'uppercase', textAlign:'center' }}>
                {e.label}
              </span>
              {activos > 0 && (
                <span style={{ fontSize:10, fontWeight:600, color:'var(--t500)' }}>{activos}</span>
              )}
            </div>
          )
        })}
      </div>

      {pedidosMostrar.length === 0 ? (
        <div className="card">
          <div className="empty-state"><Printer size={36}/><p>No hay pedidos en producción</p></div>
        </div>
      ) : (
        <div style={{ display:'flex', flexDirection:'column', gap:9 }}>
          {pedidosMostrar.map(p => {
            const abierto    = expandido === p.id
            const pct        = progresoTiempo(p.fechaIngreso, p.fechaEstimadaEntrega)
            const clase      = pct>=100?'danger':pct>=80?'warn':'ok'
            const etapaCfg   = getEtapa(p.etapaActual)
            const etapaIdx   = etapaCfg.orden - 1
            const cargandoEste = avanzando === p.id
            const puedeAvanzar = puede('avanzarEtapas')
            const puedeAsignar = puede('asignarMaquinas')

            return (
              <div key={p.id} style={{
                background:'#fff', border:'1px solid var(--g200)',
                borderRadius:12, overflow:'hidden',
                boxShadow:'0 1px 3px rgba(44,26,14,.05)',
              }}>
                {/* Barra de progreso por etapa — estilo línea */}
                <div style={{
                  display:'grid', gridTemplateColumns:``repeat(`${ETAPAS.length},1fr)``,
                  height:3,
                }}>
                  {ETAPAS.map((e,i) => (
                    <div key={e.nombre} style={{
                      background: i < etapaIdx ? 'var(--exito)'
                        : i === etapaIdx ? 'var(--t400)'
                        : 'var(--g100)',
                    }}/>
                  ))}
                </div>

                {/* Cabecera */}
                <div
                  style={{ padding:'13px 18px', cursor:'pointer', display:'flex', alignItems:'center', gap:11, flexWrap:'wrap' }}
                  onClick={() => toggle(p.id)}
                >
                  {/* Icono + número */}
                  <div style={{ display:'flex', alignItems:'center', gap:10, minWidth:140 }}>
                    <div style={{
                      padding:10, background:'#0F172A', color:'white',
                      display:'flex', alignItems:'center', justifyContent:'center',
                      flexShrink:0,
                    }}>
                      <Printer size={18}/>
                    </div>
                    <div>
                      <div style={{ fontFamily:'var(--font-mono)', fontSize:13, fontWeight:700, color:'#0F172A' }}>{p.numeroPedido}</div>
                      {p.tieneInteriorYTapa && (
                        <div style={{ display:'flex', gap:3, marginTop:3 }}>
                          <span style={{ fontSize:10, background:'#EDE7F6', color:'#4527A0', padding:'1px 5px', borderRadius:3 }}>-I</span>
                          <span style={{ fontSize:10, background:'var(--t50)', color:'var(--t700)', padding:'1px 5px', borderRadius:3 }}>-T</span>
                        </div>
                      )}
                    </div>
                  </div>

                  <div style={{ flex:1, minWidth:160 }}>
                    <div style={{ fontSize:13, fontWeight:500 }}>{p.clienteNombre}</div>
                    <div style={{ fontSize:12, color:'var(--g400)', marginTop:2 }}>{p.descripcion}</div>
                  </div>

                  <div style={{ fontSize:12, color:'var(--g500)', minWidth:110 }}>
                    {formatearMedidas(p.medidas.altoMm, p.medidas.anchoMm)}
                    <div style={{ fontSize:11, color:'var(--g400)' }}>{p.cantidadAjustada.toLocaleString()} u.</div>
                  </div>

                  <div style={{ display:'flex', flexDirection:'column', gap:4, minWidth:130 }}>
                    <StatusBadge etapa={p.etapaActual}/>
                    <StatusBadge estado={p.estado}/>
                  </div>

                  <div style={{ fontSize:12, color:'var(--g500)', minWidth:150 }}>
                    <div>Ingreso: <strong>{fFecha(p.fechaIngreso)}</strong></div>
                    <div>Estimado: <strong>{fFecha(p.fechaEstimadaEntrega)}</strong></div>
                    {p.fechaRealEntrega && <div style={{ color:'var(--exito)' }}>Real: <strong>{fFecha(p.fechaRealEntrega)}</strong></div>}
                  </div>

                  <div style={{ minWidth:100 }}>
                    <div style={{ display:'flex', justifyContent:'space-between', marginBottom:3 }}>
                      <span style={{ fontSize:11, color:'var(--g400)' }}>Progreso</span>
                      <span style={{ fontSize:11, color:'var(--g400)' }}>{pct}%</span>
                    </div>
                    <div className="prog-wrap" style={{ width:100 }}>
                      <div className={``prog-fill `${clase}``} style={{ width:```${pct}%`` }}/>
                    </div>
                  </div>

                  {/* Botones de acción rápida */}
                  {!abierto && puedeAvanzar && p.estado !== 'entregado' && (
                    <button
                      className="btn btn-primary btn-sm"
                      style={{ whiteSpace:'nowrap' }}
                      onClick={e => { e.stopPropagation(); handleAvanzarEtapa(p.id, null, ETAPAS[etapaIdx+1]?.nombre ?? p.etapaActual) }}
                      disabled={cargandoEste || etapaIdx >= ETAPAS.length-1}
                    >
                      {cargandoEste
                        ? <span className="spinner" style={{ width:14, height:14 }}/>
                        : <><ArrowRight size={13}/> Siguiente etapa</>}
                    </button>
                  )}

                  <div style={{ marginLeft:'auto', color:'var(--g400)' }}>
                    {abierto ? <ChevronUp size={18}/> : <ChevronDown size={18}/>}
                  </div>
                </div>

                {/* Asignación de máquinas — visible en cabecera si tiene subpedidos */}
                {puedeAsignar && (p.tieneInteriorYTapa) && (
                  <div style={{
                    padding:'8px 18px', borderTop:'1px solid var(--g100)',
                    display:'flex', gap:8, alignItems:'center',
                    background:'var(--t25)',
                  }}>
                    <span style={{ fontSize:12, color:'var(--g500)' }}>Máquinas:</span>
                    <button className="btn btn-ghost btn-sm" style={{ fontSize:11 }}
                      onClick={e => { e.stopPropagation(); setShowMaqModal({pedidoId:p.id,tipo:'interior'}) }}>
                      <Settings2 size={12}/> Interior: {p.maquinaInteriorNombre ?? 'Sin asignar'}
                    </button>
                    <button className="btn btn-ghost btn-sm" style={{ fontSize:11 }}
                      onClick={e => { e.stopPropagation(); setShowMaqModal({pedidoId:p.id,tipo:'tapa'}) }}>
                      <Settings2 size={12}/> Tapa: {p.maquinaTapaNombre ?? 'Sin asignar'}
                    </button>
                  </div>
                )}

                {/* Timeline expandida */}
                {abierto && (
                  <div style={{ padding:'8px 24px 20px', borderTop:'1px solid var(--g100)', background:'var(--t25)' }}>
                    <EtapaTimeline
                      pedido={p}
                      onAvanzarEtapa={puedeAvanzar ? handleAvanzarEtapa : undefined}
                      soloLectura={!puedeAvanzar}
                    />
                  </div>
                )}
              </div>
            )
          })}
        </div>
      )}

      {/* Modal asignación de máquina */}
      {showMaqModal && (
        <MaquinaSelector
          tipo={showMaqModal.tipo}
          maquinas={maquinas}
          onSeleccionar={(maqId, maqNombre) =>
            handleAsignarMaquina(showMaqModal.pedidoId, showMaqModal.tipo, maqId, maqNombre)
          }
          onClose={() => setShowMaqModal(null)}
        />
      )}
    </div>
  )
}

"@ | Set-Content -Path "src\modules\produccion\ProduccionPage.tsx" -Encoding UTF8

Write-Host "  src\modules\reportes\ReportesPage.tsx" -ForegroundColor Gray
@"
import React, { useState } from 'react'
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip,
  ResponsiveContainer, PieChart, Pie, Cell, Legend,
} from 'recharts'
import { BarChart2 } from 'lucide-react'
import { MOCK_PEDIDOS } from '@/mock/mockData'
import { ETAPAS } from '@config/etapas.config'

const COLORES = ['#7A3B1E','#9C6B3C','#C49A6C','#2D6A4F','#1A5276','#F57F17','#C0392B']

const dataPorClase = ['libro','revista','folleto','catalogo','cuaderno','otro'].map(c => ({
  name: c.charAt(0).toUpperCase() + c.slice(1),
  cantidad: MOCK_PEDIDOS.filter(p => p.claseProducto === c).length,
})).filter(d => d.cantidad > 0)

const dataTiempoEtapa = ETAPAS.slice(0, 6).map(e => ({
  etapa: e.label.length > 12 ? e.label.slice(0, 12) + '…' : e.label,
  promedio: e.tiempoRefHoras,
  real: +(e.tiempoRefHoras * (0.8 + Math.random() * 0.5)).toFixed(1),
}))

const dataEstado = [
  { name: 'En proceso', value: MOCK_PEDIDOS.filter(p => p.estado === 'en_proceso').length },
  { name: 'Entregado',  value: MOCK_PEDIDOS.filter(p => p.estado === 'entregado').length },
  { name: 'Pausado',    value: MOCK_PEDIDOS.filter(p => p.estado === 'pausado').length },
].filter(d => d.value > 0)

export default function ReportesPage() {
  const [periodo, setPeriodo] = useState('mes')

  return (
    <div>
      <div className="page-header">
        <div>
          <h1 className="page-title">Reportes</h1>
          <p className="page-subtitle">Estadísticas y análisis de producción</p>
        </div>
        <div style={{ display: 'flex', gap: 8 }}>
          {['semana','mes','trimestre'].map(p => (
            <button key={p} className={``btn btn-sm `${periodo === p ? 'btn-primary' : 'btn-ghost'}``}
              onClick={() => setPeriodo(p)}>
              {p.charAt(0).toUpperCase() + p.slice(1)}
            </button>
          ))}
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16, marginBottom: 16 }}>
        {/* Tiempo real vs estimado por etapa */}
        <div className="card">
          <h3 style={{ fontSize: 14, fontWeight: 600, marginBottom: 16 }}>Tiempo real vs estimado por etapa (horas)</h3>
          <ResponsiveContainer width="100%" height={220}>
            <BarChart data={dataTiempoEtapa} margin={{ left: -10 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#F0EDE8" />
              <XAxis dataKey="etapa" tick={{ fontSize: 10, fill: '#9C9890' }} />
              <YAxis tick={{ fontSize: 11, fill: '#9C9890' }} />
              <Tooltip contentStyle={{ fontSize: 12, borderRadius: 8 }} />
              <Legend wrapperStyle={{ fontSize: 12 }} />
              <Bar dataKey="promedio" name="Estimado" fill="var(--color-tierra-200)" radius={[3,3,0,0]} />
              <Bar dataKey="real"     name="Real"     fill="var(--color-tierra-500)" radius={[3,3,0,0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Distribución por tipo */}
        <div className="card">
          <h3 style={{ fontSize: 14, fontWeight: 600, marginBottom: 16 }}>Pedidos por tipo de producto</h3>
          <ResponsiveContainer width="100%" height={220}>
            <PieChart>
              <Pie data={dataPorClase} dataKey="cantidad" nameKey="name" cx="50%" cy="50%" outerRadius={80} label={({ name, value }) => ```${name}: `${value}``} labelLine={false}>
                {dataPorClase.map((_, i) => <Cell key={i} fill={COLORES[i % COLORES.length]} />)}
              </Pie>
              <Tooltip contentStyle={{ fontSize: 12, borderRadius: 8 }} />
            </PieChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Tabla resumen */}
      <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
        <div style={{ padding: '14px 20px', borderBottom: '1px solid #F0EDE8' }}>
          <h3 style={{ fontSize: 14, fontWeight: 600 }}>Resumen de pedidos</h3>
        </div>
        <table>
          <thead>
            <tr>
              <th>N° Pedido</th>
              <th>Cliente</th>
              <th>Producto</th>
              <th>Medidas</th>
              <th>Cantidad</th>
              <th>Estado</th>
              <th>Días en producción</th>
            </tr>
          </thead>
          <tbody>
            {MOCK_PEDIDOS.map(p => {
              const dias = Math.ceil((new Date().getTime() - p.fechaIngreso.getTime()) / 86400000)
              return (
                <tr key={p.id}>
                  <td style={{ fontFamily: 'var(--font-mono)', fontSize: 12, color: 'var(--color-tierra-600)', fontWeight: 500 }}>{p.numeroPedido}</td>
                  <td style={{ fontSize: 13 }}>{p.clienteNombre}</td>
                  <td style={{ fontSize: 12 }}>{p.claseProducto}</td>
                  <td style={{ fontSize: 12, color: '#706C65' }}>{p.medidas.altoMm}×{p.medidas.anchoMm}mm</td>
                  <td style={{ fontSize: 12, textAlign: 'right' }}>{p.cantidadOriginal.toLocaleString()}</td>
                  <td><span className={``badge badge-`${p.estado === 'entregado' ? 'entregado' : p.estado === 'en_proceso' ? 'impresion' : 'sin-ref'}``}>{p.estado}</span></td>
                  <td style={{ fontSize: 12, textAlign: 'center' }}>{p.estado === 'entregado' ? '✓' : ```${dias}d``}</td>
                </tr>
              )
            })}
          </tbody>
        </table>
      </div>
    </div>
  )
}

"@ | Set-Content -Path "src\modules\reportes\ReportesPage.tsx" -Encoding UTF8

Write-Host "  src\modules\usuarios\UsuariosPage.tsx" -ForegroundColor Gray
@"
import React, { useState, useEffect } from 'react'
import { Plus, UserCheck, UserX, Edit2, X, Eye, EyeOff } from 'lucide-react'
import {
  getUsuarios, crearUsuario,
  toggleActivoUsuario,
} from '@services/usuarios.service'
import { MOCK_USUARIOS } from '@/mock/mockData'
import { FIREBASE_CONFIGURADO } from '@services/firebase'
import type { Usuario, RolUsuario } from '@/types'

const ROL_BADGE: Record<RolUsuario, string> = {
  admin:    'badge badge-impresion',
  operario: 'badge badge-preproduccion',
  cliente:  'badge badge-ingreso',
}

interface FormNuevo {
  nombre: string
  email: string
  rol: RolUsuario
  password: string
}

export default function UsuariosPage() {
  const [usuarios,  setUsuarios]  = useState<Usuario[]>([])
  const [cargando,  setCargando]  = useState(true)
  const [showForm,  setShowForm]  = useState(false)
  const [showPwd,   setShowPwd]   = useState(false)
  const [guardando, setGuardando] = useState(false)
  const [form,      setForm]      = useState<FormNuevo>({ nombre: '', email: '', rol: 'operario', password: '' })
  const [errores,   setErrores]   = useState<Partial<FormNuevo>>({})

  useEffect(() => {
    const cargar = async () => {
      try {
        const data = await getUsuarios()
        setUsuarios(data)
      } catch {
        setUsuarios(MOCK_USUARIOS)
      } finally {
        setCargando(false)
      }
    }
    cargar()
  }, [])

  const validar = () => {
    const e: Partial<FormNuevo> = {}
    if (!form.nombre.trim()) e.nombre = 'Requerido'
    if (!form.email.trim())  e.email  = 'Requerido'
    if (!form.password || form.password.length < 6) e.password = 'Mínimo 6 caracteres'
    setErrores(e)
    return Object.keys(e).length === 0
  }

  const handleCrear = async (ev: React.FormEvent) => {
    ev.preventDefault()
    if (!validar()) return
    setGuardando(true)
    try {
      const uid = await crearUsuario(form.email.trim(), form.password, form.nombre.trim(), form.rol)
      const nuevo: Usuario = {
        uid,
        email:               form.email.trim(),
        nombre:              form.nombre.trim(),
        rol:                 form.rol,
        activo:              true,
        mustChangePassword:  true,
        creadoEn:            new Date(),
      }
      setUsuarios(prev => [...prev, nuevo])
      setShowForm(false)
      setForm({ nombre: '', email: '', rol: 'operario', password: '' })
    } catch (e) {
      setErrores({ email: e instanceof Error ? e.message : 'Error al crear usuario' })
    } finally {
      setGuardando(false)
    }
  }

  const handleToggleActivo = async (uid: string, activo: boolean) => {
    await toggleActivoUsuario(uid, !activo)
    setUsuarios(prev => prev.map(u => u.uid === uid ? { ...u, activo: !activo } : u))
  }

  if (cargando) {
    return (
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: 300, gap: 12, color: '#9C9890' }}>
        <span className="spinner" />
        <span>Cargando usuarios...</span>
      </div>
    )
  }

  return (
    <div>
      <div className="page-header">
        <div>
          <h1 className="page-title">Usuarios</h1>
          <p className="page-subtitle">{usuarios.length} usuarios registrados</p>
        </div>
        <button className="btn btn-primary" onClick={() => setShowForm(true)}>
          <Plus size={15} /> Nuevo usuario
        </button>
      </div>

      {!FIREBASE_CONFIGURADO && (
        <div className="alert alert-info" style={{ marginBottom: 16 }}>
          <span style={{ fontSize: 12 }}>Modo demo — los cambios no se persisten hasta configurar Firebase.</span>
        </div>
      )}

      <div className="table-wrapper">
        <table>
          <thead>
            <tr>
              <th>Usuario</th>
              <th>Email</th>
              <th>Rol</th>
              <th>Estado</th>
              <th>Primer login</th>
              <th>Creado</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            {usuarios.map(u => (
              <tr key={u.uid}>
                <td>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 9 }}>
                    <div style={{
                      width: 28, height: 28, borderRadius: '50%',
                      background: 'var(--color-tierra-100)', color: 'var(--color-tierra-700)',
                      display: 'flex', alignItems: 'center', justifyContent: 'center',
                      fontSize: 11, fontWeight: 600, flexShrink: 0,
                    }}>
                      {u.nombre.split(' ').map(p => p[0]).slice(0,2).join('').toUpperCase()}
                    </div>
                    <span style={{ fontSize: 13, fontWeight: 500 }}>{u.nombre}</span>
                  </div>
                </td>
                <td style={{ fontSize: 12, color: '#706C65' }}>{u.email}</td>
                <td><span className={ROL_BADGE[u.rol]}>{u.rol}</span></td>
                <td>
                  <span className={``badge `${u.activo ? 'badge-entregado' : 'badge-cancelado'}``}>
                    {u.activo ? 'Activo' : 'Inactivo'}
                  </span>
                </td>
                <td>
                  {u.mustChangePassword
                    ? <span className="badge badge-alerta">Pendiente</span>
                    : <span className="badge badge-entregado">Completado</span>}
                </td>
                <td style={{ fontSize: 12, color: '#9C9890' }}>
                  {u.creadoEn.toLocaleDateString('es-AR')}
                </td>
                <td>
                  <div style={{ display: 'flex', gap: 6 }}>
                    <button className="btn btn-ghost btn-xs" title="Editar">
                      <Edit2 size={12} />
                    </button>
                    <button
                      className={``btn btn-xs `${u.activo ? 'btn-danger' : 'btn-secondary'}``}
                      onClick={() => handleToggleActivo(u.uid, u.activo)}
                      title={u.activo ? 'Desactivar' : 'Activar'}
                    >
                      {u.activo ? <UserX size={12} /> : <UserCheck size={12} />}
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Modal nuevo usuario */}
      {showForm && (
        <div className="modal-overlay" onClick={e => e.target === e.currentTarget && setShowForm(false)}>
          <div className="modal" style={{ maxWidth: 460 }}>
            <div className="modal-header">
              <h2 className="modal-title">Nuevo usuario</h2>
              <button className="btn btn-ghost btn-sm" onClick={() => setShowForm(false)}><X size={16} /></button>
            </div>
            <div className="alert alert-info" style={{ marginBottom: 16 }}>
              <span style={{ fontSize: 12 }}>El usuario deberá cambiar su contraseña en el primer inicio de sesión.</span>
            </div>
            <form onSubmit={handleCrear} noValidate>
              <div className="form-group">
                <label className="form-label">Nombre completo <span className="form-required">*</span></label>
                <input className="input" value={form.nombre}
                  onChange={e => setForm(f => ({...f, nombre: e.target.value}))}
                  placeholder="Nombre y apellido" />
                {errores.nombre && <span className="form-error">{errores.nombre}</span>}
              </div>
              <div className="form-group">
                <label className="form-label">Email <span className="form-required">*</span></label>
                <input className="input" type="email" value={form.email}
                  onChange={e => setForm(f => ({...f, email: e.target.value}))}
                  placeholder="usuario@imprenta.com" />
                {errores.email && <span className="form-error">{errores.email}</span>}
              </div>
              <div className="form-group">
                <label className="form-label">Rol</label>
                <select className="input" value={form.rol}
                  onChange={e => setForm(f => ({...f, rol: e.target.value as RolUsuario}))}>
                  <option value="operario">Operario</option>
                  <option value="admin">Administrador</option>
                  <option value="cliente">Cliente (solo lectura)</option>
                </select>
              </div>
              <div className="form-group">
                <label className="form-label">Contraseña temporal <span className="form-required">*</span></label>
                <div style={{ position: 'relative' }}>
                  <input className="input" type={showPwd ? 'text' : 'password'}
                    value={form.password}
                    onChange={e => setForm(f => ({...f, password: e.target.value}))}
                    placeholder="Mínimo 6 caracteres"
                    style={{ paddingRight: 40 }} />
                  <button type="button" onClick={() => setShowPwd(v => !v)}
                    style={{ position: 'absolute', right: 10, top: '50%', transform: 'translateY(-50%)', background: 'none', border: 'none', color: '#9C9890', cursor: 'pointer' }}>
                    {showPwd ? <EyeOff size={15} /> : <Eye size={15} />}
                  </button>
                </div>
                {errores.password && <span className="form-error">{errores.password}</span>}
              </div>
              <div className="modal-footer">
                <button type="button" className="btn btn-ghost" onClick={() => setShowForm(false)}>Cancelar</button>
                <button type="submit" className="btn btn-primary" disabled={guardando}>
                  {guardando
                    ? <><span className="spinner" style={{ width: 14, height: 14 }} /> Creando...</>
                    : 'Crear usuario'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}

"@ | Set-Content -Path "src\modules\usuarios\UsuariosPage.tsx" -Encoding UTF8

Write-Host "  src\services\auth.service.ts" -ForegroundColor Gray
@"
import {
  signInWithEmailAndPassword,
  signOut,
  updatePassword,
  type User as FirebaseUser,
} from 'firebase/auth'
import { doc, getDoc, updateDoc, serverTimestamp } from 'firebase/firestore'
import { auth, db, FIREBASE_CONFIGURADO } from './firebase'
import {
  encriptarPassword,
  encriptarPasswordTemporal,
  verificarPasswordUniversal,
  verificarPasswordTemporal,
  type PasswordStored,
} from './crypto'
import { MOCK_USUARIOS } from '@/mock/mockData'
import type { Usuario } from '@/types'

const toUsuario = (uid: string, data: Record<string, unknown>): Usuario => ({
  uid,
  email:               data.email         as string,
  nombre:              data.nombre        as string,
  rol:                 data.rol           as Usuario['rol'],
  activo:              data.activo        as boolean,
  mustChangePassword:  data.mustChangePassword as boolean,
  creadoEn:            (data.creadoEn as { toDate?: () => Date })?.toDate?.() ?? new Date(),
  ultimoAcceso:        (data.ultimoAcceso as { toDate?: () => Date })?.toDate?.(),
  passwordStored:      data.passwordStored as PasswordStored | undefined,
})

// ── LOGIN ─────────────────────────────────────────────────────
export const loginService = async (
  email: string,
  password: string,
): Promise<Usuario> => {
  if (!FIREBASE_CONFIGURADO) {
    await new Promise(r => setTimeout(r, 600))
    const found = MOCK_USUARIOS.find(
      u => u.email.toLowerCase() === email.toLowerCase(),
    )
    if (!found)        throw new Error('Usuario no encontrado')
    if (!found.activo) throw new Error('Usuario desactivado')
    return found
  }

  // 1. Firebase Auth
  const credential = await signInWithEmailAndPassword(auth, email, password)
  const fbUser: FirebaseUser = credential.user

  // 2. Leer perfil Firestore
  const snap = await getDoc(doc(db, 'usuarios', fbUser.uid))
  if (!snap.exists()) throw new Error('Perfil de usuario no encontrado')
  const data = snap.data()

  if (!data.activo) { await signOut(auth); throw new Error('Usuario desactivado') }

  // 3. Verificar password con esquema v2 (PBKDF2 + AES + HMAC)
  if (data.passwordStored) {
    const stored = data.passwordStored as PasswordStored
    const valida = verificarPasswordUniversal(password, stored)
    if (!valida) {
      await signOut(auth)
      throw new Error('Verificacion de seguridad fallida')
    }
  }

  // 4. Actualizar ultimo acceso
  await updateDoc(doc(db, 'usuarios', fbUser.uid), {
    ultimoAcceso: serverTimestamp(),
  })

  return toUsuario(fbUser.uid, data)
}

// ── LOGOUT ────────────────────────────────────────────────────
export const logoutService = async (): Promise<void> => {
  if (!FIREBASE_CONFIGURADO) return
  await signOut(auth)
}

// ── CAMBIO PASSWORD PRIMER LOGIN ──────────────────────────────
/**
 * Flujo v2:
 * 1. Leer passwordStored (version: 1 — solo SEED_A)
 * 2. Verificar con verificarPasswordTemporal
 * 3. Encriptar nueva con esquema completo v2 (PBKDF2 + AES_A + AES_B + HMAC)
 * 4. Guardar { hash, salt, hmac, version: 2 }
 * 5. mustChangePassword = false
 */
export const cambiarPasswordPrimerLogin = async (
  uid:            string,
  passwordActual: string,
  passwordNueva:  string,
): Promise<void> => {
  if (!FIREBASE_CONFIGURADO) {
    await new Promise(r => setTimeout(r, 500))
    return
  }

  const snap = await getDoc(doc(db, 'usuarios', uid))
  if (!snap.exists()) throw new Error('Usuario no encontrado')
  const data = snap.data()

  const stored = data.passwordStored as PasswordStored
  if (!stored) throw new Error('Datos de seguridad no encontrados')

  // Verificar password actual (version 1 — temporal)
  const valida = verificarPasswordTemporal(passwordActual, stored)
  if (!valida) throw new Error('La contrasena actual no es correcta')

  if (passwordNueva.length < 8)
    throw new Error('La nueva contrasena debe tener al menos 8 caracteres')

  // Encriptar con esquema completo v2
  const passwordStored = encriptarPassword(passwordNueva)

  if (auth.currentUser) {
    await updatePassword(auth.currentUser, passwordNueva)
  }

  await updateDoc(doc(db, 'usuarios', uid), {
    passwordStored,
    mustChangePassword: false,
    actualizadoEn:      serverTimestamp(),
  })
}

// ── CAMBIO PASSWORD NORMAL ────────────────────────────────────
export const cambiarPassword = async (
  uid:            string,
  passwordActual: string,
  passwordNueva:  string,
): Promise<void> => {
  if (!FIREBASE_CONFIGURADO) {
    await new Promise(r => setTimeout(r, 500))
    return
  }

  const snap = await getDoc(doc(db, 'usuarios', uid))
  if (!snap.exists()) throw new Error('Usuario no encontrado')
  const data = snap.data()

  const stored = data.passwordStored as PasswordStored
  if (!verificarPasswordUniversal(passwordActual, stored))
    throw new Error('La contrasena actual no es correcta')

  if (passwordNueva.length < 8)
    throw new Error('La nueva contrasena debe tener al menos 8 caracteres')

  const passwordStoredNew = encriptarPassword(passwordNueva)

  if (auth.currentUser) await updatePassword(auth.currentUser, passwordNueva)

  await updateDoc(doc(db, 'usuarios', uid), {
    passwordStored:  passwordStoredNew,
    actualizadoEn:   serverTimestamp(),
  })
}

// ── OBTENER USUARIO ───────────────────────────────────────────
export const getUsuarioActual = async (uid: string): Promise<Usuario | null> => {
  if (!FIREBASE_CONFIGURADO)
    return MOCK_USUARIOS.find(u => u.uid === uid) ?? null
  const snap = await getDoc(doc(db, 'usuarios', uid))
  if (!snap.exists()) return null
  return toUsuario(uid, snap.data())
}

"@ | Set-Content -Path "src\services\auth.service.ts" -Encoding UTF8

Write-Host "  src\services\crypto.ts" -ForegroundColor Gray
@"
/**
 * crypto.ts — v2.0.0
 * PBKDF2(SHA-256, 100k iter) + AES-256(SEED_A) + AES-256(SEED_B) + HMAC-SHA256(SEED_C)
 */
import CryptoJS from 'crypto-js'

const SEED_A = import.meta.env.VITE_SEED_A ?? 'dev-seed-a-placeholder-32chars!!'
const SEED_B = import.meta.env.VITE_SEED_B ?? 'dev-seed-b-placeholder-32chars!!'
const SEED_C = import.meta.env.VITE_SEED_C ?? 'dev-seed-c-placeholder-32chars!!'

const PBKDF2_ITERATIONS = 100_000
const PBKDF2_KEY_SIZE   = 256 / 32

export interface PasswordStored {
  hash:    string
  salt:    string
  hmac:    string
  version: number
}

const generarSalt = (): string =>
  CryptoJS.lib.WordArray.random(128 / 8).toString()

const pbkdf2 = (password: string, salt: string): string =>
  CryptoJS.PBKDF2(password, salt, {
    keySize:    PBKDF2_KEY_SIZE,
    iterations: PBKDF2_ITERATIONS,
    hasher:     CryptoJS.algo.SHA256,
  }).toString()

// ── ENCRIPTACIÓN COMPLETA v2 ──────────────────────────────────
export const encriptarPassword = (password: string): PasswordStored => {
  const salt    = generarSalt()
  const derived = pbkdf2(password, salt)
  const paso1   = CryptoJS.AES.encrypt(derived, SEED_A).toString()
  const paso2   = CryptoJS.AES.encrypt(paso1,   SEED_B).toString()
  const hmac    = CryptoJS.HmacSHA256(paso2, SEED_C).toString()
  return { hash: paso2, salt, hmac, version: 2 }
}

export const verificarPassword = (
  passwordIngresada: string,
  stored: PasswordStored,
): boolean => {
  try {
    const hmacCalculado = CryptoJS.HmacSHA256(stored.hash, SEED_C).toString()
    if (hmacCalculado !== stored.hmac) {
      console.error('[SECURITY] HMAC invalido — posible manipulacion de datos')
      return false
    }
    const paso1            = CryptoJS.AES.decrypt(stored.hash, SEED_B).toString(CryptoJS.enc.Utf8)
    const derivedGuardado  = CryptoJS.AES.decrypt(paso1, SEED_A).toString(CryptoJS.enc.Utf8)
    const derivedIngresado = pbkdf2(passwordIngresada, stored.salt)
    return derivedGuardado === derivedIngresado
  } catch { return false }
}

// ── PRIMER LOGIN v1 (solo SEED_A — SEED_B abierta) ───────────
export const encriptarPasswordTemporal = (password: string): PasswordStored => {
  const salt    = generarSalt()
  const derived = pbkdf2(password, salt)
  const hash    = CryptoJS.AES.encrypt(derived, SEED_A).toString()
  const hmac    = CryptoJS.HmacSHA256(hash, SEED_C).toString()
  return { hash, salt, hmac, version: 1 }
}

export const verificarPasswordTemporal = (
  passwordIngresada: string,
  stored: PasswordStored,
): boolean => {
  try {
    const hmacCalculado    = CryptoJS.HmacSHA256(stored.hash, SEED_C).toString()
    if (hmacCalculado !== stored.hmac) return false
    const derivedGuardado  = CryptoJS.AES.decrypt(stored.hash, SEED_A).toString(CryptoJS.enc.Utf8)
    const derivedIngresado = pbkdf2(passwordIngresada, stored.salt)
    return derivedGuardado === derivedIngresado
  } catch { return false }
}

// ── UNIVERSAL — detecta version y verifica ───────────────────
export const verificarPasswordUniversal = (
  password: string,
  stored: PasswordStored,
): boolean =>
  stored.version === 1
    ? verificarPasswordTemporal(password, stored)
    : verificarPassword(password, stored)

// ── LEGACY v1.x ──────────────────────────────────────────────
export const doubleEncrypt = (text: string): string => {
  const p1 = CryptoJS.AES.encrypt(text, SEED_A).toString()
  return CryptoJS.AES.encrypt(p1, SEED_B).toString()
}
export const doubleDecrypt = (cipher: string): string => {
  const p1 = CryptoJS.AES.decrypt(cipher, SEED_B).toString(CryptoJS.enc.Utf8)
  return CryptoJS.AES.decrypt(p1, SEED_A).toString(CryptoJS.enc.Utf8)
}
export const singleEncrypt = (text: string): string =>
  CryptoJS.AES.encrypt(text, SEED_A).toString()
export const singleDecrypt = (cipher: string): string =>
  CryptoJS.AES.decrypt(cipher, SEED_A).toString(CryptoJS.enc.Utf8)
export const compareDouble = (plain: string, cipher: string): boolean => {
  try { return doubleDecrypt(cipher) === plain } catch { return false }
}

"@ | Set-Content -Path "src\services\crypto.ts" -Encoding UTF8

Write-Host "  src\services\firebase.ts" -ForegroundColor Gray
@"
import { initializeApp, getApps, type FirebaseApp } from 'firebase/app'
import { getAuth,          type Auth }           from 'firebase/auth'
import { getFirestore,     type Firestore }       from 'firebase/firestore'

// ── Configuración desde variables de entorno ──────────────────
const firebaseConfig = {
  apiKey:            import.meta.env.VITE_FIREBASE_API_KEY,
  authDomain:        import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId:         import.meta.env.VITE_FIREBASE_PROJECT_ID,
  storageBucket:     import.meta.env.VITE_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID,
  appId:             import.meta.env.VITE_FIREBASE_APP_ID,
}

// ── Verificar que las variables de entorno están cargadas ─────
const FIREBASE_CONFIGURADO = !!(
  firebaseConfig.apiKey &&
  firebaseConfig.projectId &&
  firebaseConfig.authDomain
)

// ── Inicialización (singleton — evita duplicados en HMR) ──────
let app:  FirebaseApp
let auth: Auth
let db:   Firestore

if (FIREBASE_CONFIGURADO) {
  app  = getApps().length === 0 ? initializeApp(firebaseConfig) : getApps()[0]
  auth = getAuth(app)
  db   = getFirestore(app)
} else {
  console.warn(
    '[Firebase] Variables de entorno no configuradas. ' +
    'La app corre en modo mock. Configurá el archivo .env para conectar Firebase.'
  )
  // Cast vacío — no se usarán si FIREBASE_CONFIGURADO es false
  app  = {} as FirebaseApp
  auth = {} as Auth
  db   = {} as Firestore
}

export { app, auth, db, FIREBASE_CONFIGURADO }

"@ | Set-Content -Path "src\services\firebase.ts" -Encoding UTF8

Write-Host "  src\services\firestore.service.ts" -ForegroundColor Gray
@"
import {
  collection, doc,
  getDocs, getDoc,
  addDoc, setDoc, updateDoc, deleteDoc,
  query, where, orderBy, limit,
  onSnapshot, serverTimestamp,
  type Query, type DocumentData,
  type WhereFilterOp, type OrderByDirection,
  type Unsubscribe,
} from 'firebase/firestore'
import { db, FIREBASE_CONFIGURADO } from './firebase'

// ── Tipos ─────────────────────────────────────────────────────
export interface WhereClause {
  campo:    string
  operador: WhereFilterOp
  valor:    unknown
}

export interface OrderClause {
  campo:     string
  direccion: OrderByDirection
}

export interface QueryOptions {
  wheres?:  WhereClause[]
  orders?:  OrderClause[]
  limite?:  number
}

// ── Helpers de conversión Firestore → TS ──────────────────────
const convertirTimestamps = (data: DocumentData): DocumentData => {
  const resultado: DocumentData = {}
  for (const [key, value] of Object.entries(data)) {
    if (value && typeof value === 'object' && 'toDate' in value) {
      resultado[key] = (value as { toDate: () => Date }).toDate()
    } else if (value && typeof value === 'object' && !Array.isArray(value)) {
      resultado[key] = convertirTimestamps(value as DocumentData)
    } else {
      resultado[key] = value
    }
  }
  return resultado
}

// ── LEER TODOS con opciones ───────────────────────────────────
export const getColeccion = async <T>(
  coleccionNombre: string,
  opciones?: QueryOptions,
): Promise<(T & { id: string })[]> => {
  if (!FIREBASE_CONFIGURADO) return []

  let q: Query<DocumentData> = collection(db, coleccionNombre)

  if (opciones?.wheres?.length) {
    opciones.wheres.forEach(w => {
      q = query(q, where(w.campo, w.operador, w.valor))
    })
  }
  if (opciones?.orders?.length) {
    opciones.orders.forEach(o => {
      q = query(q, orderBy(o.campo, o.direccion))
    })
  }
  if (opciones?.limite) {
    q = query(q, limit(opciones.limite))
  }

  const snap = await getDocs(q)
  return snap.docs.map(d => ({
    id: d.id,
    ...(convertirTimestamps(d.data()) as T),
  }))
}

// ── LEER UNO ──────────────────────────────────────────────────
export const getDocumento = async <T>(
  coleccion: string,
  id: string,
): Promise<(T & { id: string }) | null> => {
  if (!FIREBASE_CONFIGURADO) return null

  const snap = await getDoc(doc(db, coleccion, id))
  if (!snap.exists()) return null
  return { id: snap.id, ...(convertirTimestamps(snap.data()) as T) }
}

// ── CREAR (ID automático) ─────────────────────────────────────
export const crearDocumento = async <T extends object>(
  coleccion: string,
  datos: T,
): Promise<string> => {
  if (!FIREBASE_CONFIGURADO) return ``mock-`${Date.now()}``

  const ref = await addDoc(collection(db, coleccion), {
    ...datos,
    creadoEn:     serverTimestamp(),
    actualizadoEn: serverTimestamp(),
  })
  return ref.id
}

// ── CREAR con ID propio ───────────────────────────────────────
export const setDocumento = async <T extends object>(
  coleccionNombre: string,
  id: string,
  datos: T,
): Promise<void> => {
  if (!FIREBASE_CONFIGURADO) return

  await setDoc(doc(db, coleccionNombre, id), {
    ...datos,
    creadoEn:      serverTimestamp(),
    actualizadoEn: serverTimestamp(),
  })
}

// ── ACTUALIZAR ────────────────────────────────────────────────
export const actualizarDocumento = async <T extends object>(
  coleccionNombre: string,
  id: string,
  datos: Partial<T>,
): Promise<void> => {
  if (!FIREBASE_CONFIGURADO) return

  await updateDoc(doc(db, coleccionNombre, id), {
    ...datos,
    actualizadoEn: serverTimestamp(),
  })
}

// ── ELIMINAR ──────────────────────────────────────────────────
export const eliminarDocumento = async (
  coleccionNombre: string,
  id: string,
): Promise<void> => {
  if (!FIREBASE_CONFIGURADO) return
  await deleteDoc(doc(db, coleccionNombre, id))
}

// ── TIEMPO REAL — escuchar colección ─────────────────────────
export const escucharColeccion = <T>(
  coleccionNombre: string,
  callback: (datos: (T & { id: string })[]) => void,
  opciones?: QueryOptions,
): Unsubscribe => {
  if (!FIREBASE_CONFIGURADO) return () => {}

  let q: Query<DocumentData> = collection(db, coleccionNombre)

  if (opciones?.wheres?.length) {
    opciones.wheres.forEach(w => {
      q = query(q, where(w.campo, w.operador, w.valor))
    })
  }
  if (opciones?.orders?.length) {
    opciones.orders.forEach(o => {
      q = query(q, orderBy(o.campo, o.direccion))
    })
  }

  return onSnapshot(q, snap => {
    const datos = snap.docs.map(d => ({
      id: d.id,
      ...(convertirTimestamps(d.data()) as T),
    }))
    callback(datos)
  })
}

// ── TIEMPO REAL — escuchar un documento ───────────────────────
export const escucharDocumento = <T>(
  coleccionNombre: string,
  id: string,
  callback: (dato: (T & { id: string }) | null) => void,
): Unsubscribe => {
  if (!FIREBASE_CONFIGURADO) return () => {}

  return onSnapshot(doc(db, coleccionNombre, id), snap => {
    if (!snap.exists()) { callback(null); return }
    callback({ id: snap.id, ...(convertirTimestamps(snap.data()) as T) })
  })
}

"@ | Set-Content -Path "src\services\firestore.service.ts" -Encoding UTF8

Write-Host "  src\services\maquinas.service.ts" -ForegroundColor Gray
@"
import { FIREBASE_CONFIGURADO } from './firebase'
import {
  getColeccion, crearDocumento,
  actualizarDocumento, eliminarDocumento,
} from './firestore.service'
import { escucharColeccion } from './firestore.service'
import { MOCK_MAQUINAS } from '@/mock/mockData'
import type { Maquina, TipoMaquina } from '@/types'
import type { Unsubscribe } from 'firebase/firestore'

const COLECCION = 'maquinas'

// ── OBTENER TODAS ─────────────────────────────────────────────
export const getMaquinas = async (): Promise<Maquina[]> => {
  if (!FIREBASE_CONFIGURADO) return MOCK_MAQUINAS

  const docs = await getColeccion<Maquina>(COLECCION, {
    orders: [{ campo: 'nombre', direccion: 'asc' }],
  })
  return docs as Maquina[]
}

// ── OBTENER POR TIPO ──────────────────────────────────────────
export const getMaquinasPorTipo = async (tipo: TipoMaquina): Promise<Maquina[]> => {
  if (!FIREBASE_CONFIGURADO) {
    return MOCK_MAQUINAS.filter(m => m.tipo === tipo || m.tipo === 'mixta')
  }

  const docs = await getColeccion<Maquina>(COLECCION, {
    wheres: [{ campo: 'tipo', operador: 'in', valor: [tipo, 'mixta'] }],
  })
  return docs as Maquina[]
}

// ── CREAR MÁQUINA ─────────────────────────────────────────────
export const crearMaquina = async (
  maquina: Omit<Maquina, 'id' | 'pedidosActivos'>,
): Promise<string> => {
  if (!FIREBASE_CONFIGURADO) return ``mock-maq-`${Date.now()}``

  return crearDocumento(COLECCION, {
    ...maquina,
    pedidosActivos: [],
  })
}

// ── ACTUALIZAR MÁQUINA ────────────────────────────────────────
export const actualizarMaquina = async (
  id:    string,
  datos: Partial<Maquina>,
): Promise<void> => {
  if (!FIREBASE_CONFIGURADO) return
  await actualizarDocumento<Maquina>(COLECCION, id, datos)
}

// ── ASIGNAR PEDIDO A MÁQUINA ──────────────────────────────────
export const asignarPedidoAMaquina = async (
  maquinaId: string,
  pedidoId:  string,
): Promise<void> => {
  if (!FIREBASE_CONFIGURADO) return

  const maquinas = await getMaquinas()
  const maquina  = maquinas.find(m => m.id === maquinaId)
  if (!maquina) return

  const pedidosActivos = [...new Set([...maquina.pedidosActivos, pedidoId])]
  await actualizarDocumento(COLECCION, maquinaId, { pedidosActivos })
}

// ── DESASIGNAR PEDIDO DE MÁQUINA ──────────────────────────────
export const desasignarPedidoDeMaquina = async (
  maquinaId: string,
  pedidoId:  string,
): Promise<void> => {
  if (!FIREBASE_CONFIGURADO) return

  const maquinas = await getMaquinas()
  const maquina  = maquinas.find(m => m.id === maquinaId)
  if (!maquina) return

  const pedidosActivos = maquina.pedidosActivos.filter(id => id !== pedidoId)
  await actualizarDocumento(COLECCION, maquinaId, { pedidosActivos })
}

// ── ESCUCHAR EN TIEMPO REAL ───────────────────────────────────
export const escucharMaquinas = (
  callback: (maquinas: Maquina[]) => void,
): Unsubscribe => {
  if (!FIREBASE_CONFIGURADO) {
    callback(MOCK_MAQUINAS)
    return () => {}
  }
  return escucharColeccion<Maquina>(COLECCION, callback)
}

"@ | Set-Content -Path "src\services\maquinas.service.ts" -Encoding UTF8

Write-Host "  src\services\pedidos.service.ts" -ForegroundColor Gray
@"
import {
  collection, doc, addDoc, updateDoc,
  serverTimestamp, onSnapshot,
  query, orderBy, where,
  type Unsubscribe,
} from 'firebase/firestore'
import { db, FIREBASE_CONFIGURADO } from './firebase'
import {
  getColeccion, getDocumento,
  actualizarDocumento, setDocumento,
} from './firestore.service'
import { MOCK_PEDIDOS } from '@/mock/mockData'
import type { Pedido, EtapaRegistro, NombreEtapa, SubPedido } from '@/types'
import { generarNumeroPedido } from '@/utils/pedido'

const COLECCION = 'pedidos'

// ── Helpers de conversión ─────────────────────────────────────
const pedidoToFirestore = (p: Partial<Pedido>) => ({
  numeroPedido:          p.numeroPedido,
  clienteUid:            p.clienteUid,
  clienteNombre:         p.clienteNombre,
  descripcion:           p.descripcion,
  claseProducto:         p.claseProducto,
  medidas:               p.medidas,
  cantidadOriginal:      p.cantidadOriginal,
  mermaProcentaje:       p.mermaProcentaje,
  cantidadAjustada:      p.cantidadAjustada,
  tieneInteriorYTapa:    p.tieneInteriorYTapa,
  estado:                p.estado,
  etapaActual:           p.etapaActual,
  fechaIngreso:          p.fechaIngreso,
  fechaEstimadaEntrega:  p.fechaEstimadaEntrega,
  fechaRealEntrega:      p.fechaRealEntrega ?? null,
  creadoPor:             p.creadoPor,
  observaciones:         p.observaciones ?? null,
  archivosRef:           p.archivosRef ?? [],
})

// ── CREAR PEDIDO ──────────────────────────────────────────────
export const crearPedido = async (
  pedido: Omit<Pedido, 'id' | 'actualizadoEn' | 'subPedidos'>,
): Promise<string> => {

  if (!FIREBASE_CONFIGURADO) {
    // Mock: devuelve el numero pedido como ID
    return pedido.numeroPedido
  }

  const ref = await addDoc(collection(db, COLECCION), {
    ...pedidoToFirestore(pedido),
    subPedidos:    [],
    creadoEn:      serverTimestamp(),
    actualizadoEn: serverTimestamp(),
  })

  // Si tiene interior y tapa, crear sub-pedidos como sub-colección
  if (pedido.tieneInteriorYTapa) {
    const subI: Omit<SubPedido, 'etapas'> = {
      id:         ```${pedido.numeroPedido}-I``,
      pedidoId:   ref.id,
      tipo:       'interior',
      etapaActual: 'ingreso_pedido',
      cantidad:   pedido.cantidadAjustada,
      fechaInicio: pedido.fechaIngreso,
      completado: false,
    }
    const subT: Omit<SubPedido, 'etapas'> = {
      id:         ```${pedido.numeroPedido}-T``,
      pedidoId:   ref.id,
      tipo:       'tapa',
      etapaActual: 'ingreso_pedido',
      cantidad:   pedido.cantidadAjustada,
      fechaInicio: pedido.fechaIngreso,
      completado: false,
    }
    await setDocumento(```${COLECCION}/`${ref.id}/subPedidos``, subI.id, { ...subI, etapas: [] })
    await setDocumento(```${COLECCION}/`${ref.id}/subPedidos``, subT.id, { ...subT, etapas: [] })
  }

  return ref.id
}

// ── OBTENER TODOS (con fallback mock) ─────────────────────────
export const getPedidos = async (): Promise<Pedido[]> => {
  if (!FIREBASE_CONFIGURADO) return MOCK_PEDIDOS

  const docs = await getColeccion<Pedido>(COLECCION, {
    orders: [{ campo: 'fechaIngreso', direccion: 'desc' }],
  })
  return docs as Pedido[]
}

// ── OBTENER POR CLIENTE (rol cliente) ─────────────────────────
export const getPedidosPorCliente = async (clienteUid: string): Promise<Pedido[]> => {
  if (!FIREBASE_CONFIGURADO) {
    return MOCK_PEDIDOS.filter(p => p.clienteUid === clienteUid)
  }

  const docs = await getColeccion<Pedido>(COLECCION, {
    wheres: [{ campo: 'clienteUid', operador: '==', valor: clienteUid }],
    orders: [{ campo: 'fechaIngreso', direccion: 'desc' }],
  })
  return docs as Pedido[]
}

// ── OBTENER UNO ───────────────────────────────────────────────
export const getPedido = async (id: string): Promise<Pedido | null> => {
  if (!FIREBASE_CONFIGURADO) {
    return MOCK_PEDIDOS.find(p => p.id === id) ?? null
  }
  return getDocumento<Pedido>(COLECCION, id)
}

// ── ACTUALIZAR ETAPA PRINCIPAL ────────────────────────────────
export const avanzarEtapaPedido = async (
  pedidoId:    string,
  nuevaEtapa:  NombreEtapa,
  usuarioUid:  string,
  usuarioNombre: string,
  maquinaId?:  string,
  maquinaNombre?: string,
  notas?:      string,
): Promise<void> => {
  if (!FIREBASE_CONFIGURADO) return

  const etapaReg: Omit<EtapaRegistro, 'id'> = {
    nombre:         nuevaEtapa,
    fechaInicio:    new Date(),
    usuarioUid,
    usuarioNombre,
    maquinaId,
    maquinaNombre,
    notas,
    alertaActiva:   false,
    sinReferencia:  true,
  }

  // Registrar en sub-colección etapas del pedido
  await addDoc(
    collection(db, ```${COLECCION}/`${pedidoId}/etapas``),
    { ...etapaReg, fechaInicio: serverTimestamp() }
  )

  // Actualizar etapa actual en el documento principal
  await updateDoc(doc(db, COLECCION, pedidoId), {
    etapaActual:   nuevaEtapa,
    actualizadoEn: serverTimestamp(),
    ...(nuevaEtapa === 'entregado' ? { fechaRealEntrega: serverTimestamp() } : {}),
  })
}

// ── FINALIZAR ETAPA (cerrar fechaFin) ─────────────────────────
export const finalizarEtapa = async (
  pedidoId:  string,
  etapaId:   string,
): Promise<void> => {
  if (!FIREBASE_CONFIGURADO) return

  await updateDoc(
    doc(db, ```${COLECCION}/`${pedidoId}/etapas``, etapaId),
    { fechaFin: serverTimestamp(), duracionMinutos: 0 }
  )
}

// ── ESCUCHAR PEDIDOS EN TIEMPO REAL ───────────────────────────
export const escucharPedidos = (
  callback:   (pedidos: Pedido[]) => void,
  clienteUid?: string,
): Unsubscribe => {
  if (!FIREBASE_CONFIGURADO) {
    callback(MOCK_PEDIDOS)
    return () => {}
  }

  let q = clienteUid
    ? query(
        collection(db, COLECCION),
        where('clienteUid', '==', clienteUid),
        orderBy('fechaIngreso', 'desc'),
      )
    : query(
        collection(db, COLECCION),
        orderBy('fechaIngreso', 'desc'),
      )

  return onSnapshot(q, snap => {
    const pedidos = snap.docs.map(d => ({
      id: d.id,
      ...d.data(),
    })) as Pedido[]
    callback(pedidos)
  })
}

// ── ACTUALIZAR CAMPOS GENERALES ───────────────────────────────
export const actualizarPedido = async (
  id: string,
  datos: Partial<Pedido>,
): Promise<void> => {
  if (!FIREBASE_CONFIGURADO) return
  await actualizarDocumento<Pedido>(COLECCION, id, datos)
}

"@ | Set-Content -Path "src\services\pedidos.service.ts" -Encoding UTF8

Write-Host "  src\services\usuarios.service.ts" -ForegroundColor Gray
@"
import { createUserWithEmailAndPassword, updateProfile } from 'firebase/auth'
import { serverTimestamp } from 'firebase/firestore'
import { auth, db, FIREBASE_CONFIGURADO } from './firebase'
import { setDocumento, actualizarDocumento, getColeccion } from './firestore.service'
import { singleEncrypt } from './crypto'
import { MOCK_USUARIOS } from '@/mock/mockData'
import type { Usuario, RolUsuario } from '@/types'

const COLECCION = 'usuarios'

// ── OBTENER TODOS ─────────────────────────────────────────────
export const getUsuarios = async (): Promise<Usuario[]> => {
  if (!FIREBASE_CONFIGURADO) return MOCK_USUARIOS

  const docs = await getColeccion<Usuario>(COLECCION, {
    orders: [{ campo: 'creadoEn', direccion: 'asc' }],
  })
  return docs as Usuario[]
}

// ── CREAR USUARIO ─────────────────────────────────────────────
/**
 * 1. Crea el usuario en Firebase Auth
 * 2. Encripta la password temporal con Seed A (primer login abierto)
 * 3. Crea el documento en Firestore con mustChangePassword: true
 */
export const crearUsuario = async (
  email:    string,
  password: string,
  nombre:   string,
  rol:      RolUsuario,
): Promise<string> => {
  if (!FIREBASE_CONFIGURADO) {
    return ``mock-user-`${Date.now()}``
  }

  // Crear en Firebase Auth
  const credential = await createUserWithEmailAndPassword(auth, email, password)
  const uid = credential.user.uid

  // Actualizar displayName
  await updateProfile(credential.user, { displayName: nombre })

  // Encriptar password temporal solo con Seed A
  const passwordEncrypted = singleEncrypt(password)

  // Crear en Firestore
  await setDocumento(COLECCION, uid, {
    email,
    nombre,
    rol,
    activo:              true,
    mustChangePassword:  true,
    passwordEncrypted,
    creadoEn:            serverTimestamp(),
    actualizadoEn:       serverTimestamp(),
  })

  return uid
}

// ── ACTIVAR / DESACTIVAR USUARIO ──────────────────────────────
export const toggleActivoUsuario = async (
  uid:    string,
  activo: boolean,
): Promise<void> => {
  if (!FIREBASE_CONFIGURADO) return
  await actualizarDocumento(COLECCION, uid, { activo })
}

// ── ACTUALIZAR ROL ────────────────────────────────────────────
export const actualizarRolUsuario = async (
  uid: string,
  rol: RolUsuario,
): Promise<void> => {
  if (!FIREBASE_CONFIGURADO) return
  await actualizarDocumento(COLECCION, uid, { rol })
}

// ── ACTUALIZAR NOMBRE ─────────────────────────────────────────
export const actualizarNombreUsuario = async (
  uid:    string,
  nombre: string,
): Promise<void> => {
  if (!FIREBASE_CONFIGURADO) return
  await actualizarDocumento(COLECCION, uid, { nombre })
  if (auth.currentUser?.uid === uid) {
    await updateProfile(auth.currentUser, { displayName: nombre })
  }
}

"@ | Set-Content -Path "src\services\usuarios.service.ts" -Encoding UTF8

Write-Host "  src\styles\globals.css" -ForegroundColor Gray
@"
@import "tailwindcss";

/* ═══════════════════════════════════════════════════════════
   TEMA TIERRA — tokens de diseño vía Tailwind 4 @theme
   Disponibles como clases: bg-tierra-500, text-tierra-800, etc.
═══════════════════════════════════════════════════════════ */
@theme {
  /* Paleta tierra */
  --color-tierra-900: #1A0E06;
  --color-tierra-800: #2C1A0E;
  --color-tierra-700: #3D2410;
  --color-tierra-600: #5C3317;
  --color-tierra-500: #7A3B1E;
  --color-tierra-400: #9C6B3C;
  --color-tierra-300: #C49A6C;
  --color-tierra-200: #D4A96A;
  --color-tierra-100: #E8C99A;
  --color-tierra-50:  #F5EDE0;
  --color-tierra-25:  #FAF6F0;

  /* Semánticos */
  --color-exito:        #2D6A4F;
  --color-exito-light:  #D8F3DC;
  --color-exito-dark:   #1B4332;
  --color-alerta:       #9C4F00;
  --color-alerta-light: #FFF3CD;
  --color-alerta-dark:  #7A3B00;
  --color-peligro:      #C0392B;
  --color-peligro-light:#FDECEA;
  --color-peligro-dark: #7B241C;
  --color-info:         #1A5276;
  --color-info-light:   #D6EAF8;
  --color-info-dark:    #0D3B6E;

  /* Tipografía */
  --font-sans: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  --font-mono: 'JetBrains Mono', 'Fira Code', 'Consolas', monospace;

  /* Sidebar */
  --sidebar-width: 220px;
  --navbar-height: 52px;
}

/* ═══════════════════════════════════════════════════════════
   RESET Y BASE
═══════════════════════════════════════════════════════════ */
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap');

*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

html {
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

body {
  font-family: var(--font-sans);
  font-size: 14px;
  line-height: 1.6;
  color: #1A1916;
  background-color: var(--color-tierra-25);
  min-height: 100vh;
}

#root { min-height: 100vh; display: flex; flex-direction: column; }

/* ═══════════════════════════════════════════════════════════
   LAYOUT PRINCIPAL
═══════════════════════════════════════════════════════════ */
.app-layout {
  display: flex;
  min-height: 100vh;
}

.app-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  margin-left: var(--sidebar-width);
  min-height: 100vh;
  transition: margin-left 200ms ease;
}

.page-content {
  padding: 24px 32px;
  flex: 1;
}

@media (max-width: 768px) {
  .app-main { margin-left: 0; }
  .page-content { padding: 16px; }
}

/* ═══════════════════════════════════════════════════════════
   SIDEBAR
═══════════════════════════════════════════════════════════ */
.sidebar {
  position: fixed;
  top: 0; left: 0;
  width: var(--sidebar-width);
  height: 100vh;
  background: var(--color-tierra-800);
  display: flex;
  flex-direction: column;
  z-index: 40;
  overflow-y: auto;
}

.sidebar-logo {
  padding: 20px 20px 16px;
  border-bottom: 1px solid rgba(212,169,106,0.15);
}

.sidebar-logo-text {
  font-size: 17px;
  font-weight: 600;
  color: var(--color-tierra-50);
  letter-spacing: 0.08em;
}

.sidebar-logo-sub {
  font-size: 10px;
  color: var(--color-tierra-300);
  letter-spacing: 0.1em;
  text-transform: uppercase;
  margin-top: 2px;
}

.sidebar-nav {
  padding: 12px 10px;
  flex: 1;
}

.sidebar-section-label {
  font-size: 10px;
  font-weight: 500;
  color: var(--color-tierra-400);
  text-transform: uppercase;
  letter-spacing: 0.1em;
  padding: 12px 10px 6px;
}

.sidebar-item {
  display: flex;
  align-items: center;
  gap: 9px;
  padding: 8px 10px;
  border-radius: 7px;
  font-size: 13px;
  font-weight: 500;
  color: var(--color-tierra-200);
  text-decoration: none;
  transition: background 150ms ease, color 150ms ease;
  margin-bottom: 2px;
  cursor: pointer;
  border: none;
  background: none;
  width: 100%;
  text-align: left;
}

.sidebar-item:hover {
  background: rgba(212,169,106,0.1);
  color: var(--color-tierra-50);
}

.sidebar-item.active {
  background: rgba(122,59,30,0.5);
  color: var(--color-tierra-50);
}

.sidebar-item svg { flex-shrink: 0; opacity: 0.85; }

.sidebar-footer {
  padding: 12px 10px;
  border-top: 1px solid rgba(212,169,106,0.12);
}

/* ═══════════════════════════════════════════════════════════
   NAVBAR SUPERIOR
═══════════════════════════════════════════════════════════ */
.navbar {
  height: var(--navbar-height);
  background: white;
  border-bottom: 1px solid #E0DDD8;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 32px;
  position: sticky;
  top: 0;
  z-index: 30;
  box-shadow: 0 1px 3px rgba(44,26,14,0.06);
}

.navbar-title {
  font-size: 15px;
  font-weight: 600;
  color: #2E2C28;
}

.navbar-right {
  display: flex;
  align-items: center;
  gap: 12px;
}

.navbar-user {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: #4A4740;
}

.navbar-avatar {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  background: var(--color-tierra-500);
  color: var(--color-tierra-50);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: 600;
  flex-shrink: 0;
}

/* ═══════════════════════════════════════════════════════════
   PAGE HEADER
═══════════════════════════════════════════════════════════ */
.page-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  margin-bottom: 24px;
  gap: 16px;
  flex-wrap: wrap;
}

.page-title {
  font-size: 22px;
  font-weight: 600;
  color: #1A1916;
  line-height: 1.3;
}

.page-subtitle {
  font-size: 13px;
  color: #706C65;
  margin-top: 3px;
}

/* ═══════════════════════════════════════════════════════════
   CARDS
═══════════════════════════════════════════════════════════ */
.card {
  background: white;
  border: 1px solid #E0DDD8;
  border-radius: 12px;
  padding: 20px 24px;
  box-shadow: 0 1px 3px rgba(44,26,14,0.05);
}

.card-sm {
  background: white;
  border: 1px solid #E0DDD8;
  border-radius: 8px;
  padding: 14px 16px;
  box-shadow: 0 1px 2px rgba(44,26,14,0.04);
}

.card-surface {
  background: var(--color-tierra-50);
  border: 1px solid var(--color-tierra-100);
  border-radius: 8px;
  padding: 14px 16px;
}

/* ═══════════════════════════════════════════════════════════
   KPI CARD
═══════════════════════════════════════════════════════════ */
.kpi-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 16px;
  margin-bottom: 24px;
}

.kpi-card {
  background: white;
  border: 1px solid #E0DDD8;
  border-radius: 12px;
  padding: 18px 20px;
  box-shadow: 0 1px 3px rgba(44,26,14,0.05);
}

.kpi-label {
  font-size: 11px;
  font-weight: 500;
  color: #9C9890;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  margin-bottom: 8px;
}

.kpi-value {
  font-size: 28px;
  font-weight: 600;
  color: #1A1916;
  line-height: 1;
  margin-bottom: 6px;
}

.kpi-trend {
  font-size: 12px;
  display: flex;
  align-items: center;
  gap: 4px;
}

.kpi-trend.up   { color: var(--color-exito); }
.kpi-trend.down { color: var(--color-peligro); }
.kpi-trend.neutral { color: #9C9890; }

/* ═══════════════════════════════════════════════════════════
   BOTONES
═══════════════════════════════════════════════════════════ */
.btn {
  display: inline-flex;
  align-items: center;
  gap: 7px;
  padding: 7px 16px;
  border-radius: 7px;
  font-size: 13px;
  font-weight: 500;
  line-height: 1;
  transition: background 120ms ease, box-shadow 120ms ease;
  white-space: nowrap;
  cursor: pointer;
  border: 1px solid transparent;
  text-decoration: none;
}

.btn-primary {
  background: var(--color-tierra-500);
  color: var(--color-tierra-50);
  border-color: var(--color-tierra-600);
}
.btn-primary:hover { background: var(--color-tierra-600); }

.btn-secondary {
  background: var(--color-tierra-50);
  color: var(--color-tierra-600);
  border-color: var(--color-tierra-200);
}
.btn-secondary:hover { background: var(--color-tierra-100); }

.btn-ghost {
  background: transparent;
  color: #706C65;
  border-color: #E0DDD8;
}
.btn-ghost:hover { background: var(--color-tierra-50); color: #2E2C28; }

.btn-danger {
  background: var(--color-peligro-light);
  color: var(--color-peligro-dark);
  border-color: var(--color-peligro);
}
.btn-danger:hover { background: var(--color-peligro); color: white; }

.btn-sm { padding: 5px 11px; font-size: 12px; }
.btn-xs { padding: 3px 9px;  font-size: 11px; }

.btn:disabled { opacity: 0.45; cursor: not-allowed; }

/* ═══════════════════════════════════════════════════════════
   INPUTS Y FORMULARIOS
═══════════════════════════════════════════════════════════ */
.form-group {
  display: flex;
  flex-direction: column;
  gap: 5px;
  margin-bottom: 16px;
}

.form-label {
  font-size: 12px;
  font-weight: 500;
  color: #706C65;
}

.form-required { color: var(--color-peligro); margin-left: 2px; }

.input {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid #E0DDD8;
  border-radius: 7px;
  background: white;
  color: #1A1916;
  font-size: 14px;
  font-family: var(--font-sans);
  transition: border-color 150ms ease, box-shadow 150ms ease;
}
.input:hover  { border-color: var(--color-tierra-200); }
.input:focus  {
  outline: none;
  border-color: var(--color-tierra-400);
  box-shadow: 0 0 0 3px rgba(122,59,30,0.1);
}
.input::placeholder { color: #C8C4BE; }
.input:disabled { background: #F0EDE8; color: #9C9890; cursor: not-allowed; }

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.form-row-3 {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 16px;
}

.form-error { font-size: 11px; color: var(--color-peligro); }

/* ═══════════════════════════════════════════════════════════
   TABLA
═══════════════════════════════════════════════════════════ */
.table-wrapper {
  overflow-x: auto;
  border: 1px solid #E0DDD8;
  border-radius: 12px;
  background: white;
}

table { width: 100%; border-collapse: collapse; font-size: 13px; }

thead th {
  text-align: left;
  padding: 10px 14px;
  font-size: 11px;
  font-weight: 500;
  color: #9C9890;
  background: var(--color-tierra-50);
  border-bottom: 1px solid #E0DDD8;
  white-space: nowrap;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

tbody td {
  padding: 12px 14px;
  border-bottom: 1px solid #F0EDE8;
  color: #2E2C28;
  vertical-align: middle;
}

tbody tr:last-child td { border-bottom: none; }
tbody tr:hover td { background: var(--color-tierra-25); }

/* ═══════════════════════════════════════════════════════════
   BADGES DE ESTADO DE ETAPA
═══════════════════════════════════════════════════════════ */
.badge {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  padding: 3px 9px;
  border-radius: 999px;
  font-size: 11px;
  font-weight: 500;
  white-space: nowrap;
}

.badge-ingreso        { background: var(--color-info-light);   color: var(--color-info-dark); }
.badge-preparado      { background: #EDE7F6;                   color: #4527A0; }
.badge-preproduccion  { background: #E8F5E9;                   color: #1B5E20; }
.badge-impresion      { background: var(--color-tierra-50);    color: var(--color-tierra-700); }
.badge-encuadernacion { background: #FFF8E1;                   color: #F57F17; }
.badge-remito         { background: #FCE4EC;                   color: #880E4F; }
.badge-entregado      { background: var(--color-exito-light);  color: var(--color-exito-dark); }
.badge-alerta         { background: var(--color-alerta-light); color: var(--color-alerta-dark); }
.badge-sin-ref        { background: #F0EDE8;                   color: #9C9890; }
.badge-pausado        { background: #ECEFF1;                   color: #455A64; }
.badge-cancelado      { background: var(--color-peligro-light);color: var(--color-peligro-dark); }

/* Dot de estado */
.dot {
  width: 7px; height: 7px;
  border-radius: 50%;
  display: inline-block;
  flex-shrink: 0;
}
.dot-exito   { background: var(--color-exito); }
.dot-alerta  { background: var(--color-alerta); }
.dot-peligro { background: var(--color-peligro); }
.dot-info    { background: var(--color-info); }
.dot-neutro  { background: #C8C4BE; }

/* ═══════════════════════════════════════════════════════════
   TIMELINE DE ETAPAS
═══════════════════════════════════════════════════════════ */
.timeline {
  position: relative;
  padding-left: 28px;
}

.timeline::before {
  content: '';
  position: absolute;
  left: 9px; top: 0; bottom: 0;
  width: 1px;
  background: linear-gradient(to bottom, var(--color-tierra-200), transparent);
}

.timeline-item {
  position: relative;
  margin-bottom: 20px;
}

.timeline-dot {
  position: absolute;
  left: -23px; top: 4px;
  width: 14px; height: 14px;
  border-radius: 50%;
  border: 2px solid white;
  box-shadow: 0 0 0 1px var(--color-tierra-200);
  background: #C8C4BE;
}

.timeline-dot.completado { background: var(--color-exito);  box-shadow: 0 0 0 1px var(--color-exito); }
.timeline-dot.en-curso   { background: var(--color-tierra-400); box-shadow: 0 0 0 1px var(--color-tierra-400); animation: pulse 2s infinite; }
.timeline-dot.alerta     { background: var(--color-alerta); box-shadow: 0 0 0 1px var(--color-alerta); }

@keyframes pulse {
  0%, 100% { box-shadow: 0 0 0 1px var(--color-tierra-400); }
  50%       { box-shadow: 0 0 0 4px rgba(156,107,60,0.3); }
}

.timeline-content {
  background: white;
  border: 1px solid #E0DDD8;
  border-radius: 8px;
  padding: 12px 14px;
}

.timeline-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  margin-bottom: 6px;
  flex-wrap: wrap;
}

.timeline-etapa-name {
  font-size: 13px;
  font-weight: 500;
  color: #2E2C28;
}

.timeline-dates {
  font-size: 11px;
  color: #9C9890;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.timeline-meta {
  font-size: 11px;
  color: #706C65;
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  margin-top: 4px;
}

/* ═══════════════════════════════════════════════════════════
   BARRA DE PROGRESO DE PEDIDO (fechas)
═══════════════════════════════════════════════════════════ */
.progress-bar-wrap {
  background: #F0EDE8;
  border-radius: 999px;
  height: 6px;
  overflow: hidden;
}

.progress-bar-fill {
  height: 100%;
  border-radius: 999px;
  background: var(--color-tierra-400);
  transition: width 400ms ease;
}

.progress-bar-fill.ok      { background: var(--color-exito); }
.progress-bar-fill.warning { background: var(--color-alerta); }
.progress-bar-fill.danger  { background: var(--color-peligro); }

/* ═══════════════════════════════════════════════════════════
   MODAL / DIALOG
═══════════════════════════════════════════════════════════ */
.modal-overlay {
  position: fixed; inset: 0;
  background: rgba(26,14,6,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 50;
  padding: 16px;
}

.modal {
  background: white;
  border-radius: 14px;
  padding: 24px;
  width: 100%;
  max-width: 540px;
  box-shadow: 0 8px 32px rgba(26,14,6,0.2);
  max-height: 90vh;
  overflow-y: auto;
}

.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 20px;
}

.modal-title {
  font-size: 17px;
  font-weight: 600;
  color: #1A1916;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 24px;
  padding-top: 16px;
  border-top: 1px solid #F0EDE8;
}

/* ═══════════════════════════════════════════════════════════
   ALERTAS / NOTIFICACIONES
═══════════════════════════════════════════════════════════ */
.alert {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  padding: 12px 14px;
  border-radius: 8px;
  font-size: 13px;
  border: 1px solid;
  margin-bottom: 12px;
}

.alert-warning { background: var(--color-alerta-light); border-color: #F0C040; color: var(--color-alerta-dark); }
.alert-danger  { background: var(--color-peligro-light); border-color: var(--color-peligro); color: var(--color-peligro-dark); }
.alert-info    { background: var(--color-info-light); border-color: var(--color-info); color: var(--color-info-dark); }
.alert-success { background: var(--color-exito-light); border-color: var(--color-exito); color: var(--color-exito-dark); }

/* ═══════════════════════════════════════════════════════════
   LOGIN
═══════════════════════════════════════════════════════════ */
.login-page {
  min-height: 100vh;
  background: linear-gradient(135deg, var(--color-tierra-800) 0%, var(--color-tierra-600) 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;
}

.login-card {
  background: white;
  border-radius: 16px;
  padding: 40px 36px;
  width: 100%;
  max-width: 400px;
  box-shadow: 0 16px 48px rgba(26,14,6,0.3);
}

.login-logo {
  text-align: center;
  margin-bottom: 32px;
}

.login-logo-name {
  font-size: 24px;
  font-weight: 600;
  color: var(--color-tierra-700);
  letter-spacing: 0.1em;
}

.login-logo-sub {
  font-size: 12px;
  color: #9C9890;
  margin-top: 4px;
  letter-spacing: 0.05em;
  text-transform: uppercase;
}

/* ═══════════════════════════════════════════════════════════
   EMPTY STATE
═══════════════════════════════════════════════════════════ */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 48px 24px;
  text-align: center;
  color: #9C9890;
}

.empty-state svg { opacity: 0.35; margin-bottom: 14px; }
.empty-state p   { font-size: 14px; }

/* ═══════════════════════════════════════════════════════════
   SPINNER
═══════════════════════════════════════════════════════════ */
.spinner {
  width: 20px; height: 20px;
  border: 2px solid #E0DDD8;
  border-top-color: var(--color-tierra-500);
  border-radius: 50%;
  animation: spin 600ms linear infinite;
  display: inline-block;
}
@keyframes spin { to { transform: rotate(360deg); } }

/* ═══════════════════════════════════════════════════════════
   SECCIÓN DE SUBPEDIDO (Interior / Tapa)
═══════════════════════════════════════════════════════════ */
.subpedido-tabs {
  display: flex;
  gap: 8px;
  margin-bottom: 16px;
}

.subpedido-tab {
  padding: 6px 16px;
  border-radius: 7px;
  font-size: 12px;
  font-weight: 500;
  cursor: pointer;
  border: 1px solid #E0DDD8;
  background: white;
  color: #706C65;
  transition: all 150ms ease;
}

.subpedido-tab.active-interior {
  background: #EDE7F6; color: #4527A0; border-color: #C5CAE9;
}

.subpedido-tab.active-tapa {
  background: var(--color-tierra-50); color: var(--color-tierra-700); border-color: var(--color-tierra-200);
}

/* ═══════════════════════════════════════════════════════════
   FILTROS
═══════════════════════════════════════════════════════════ */
.filtros-bar {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
  align-items: flex-end;
  background: white;
  border: 1px solid #E0DDD8;
  border-radius: 10px;
  padding: 14px 16px;
  margin-bottom: 16px;
}

/* ═══════════════════════════════════════════════════════════
   DIVISOR
═══════════════════════════════════════════════════════════ */
.divider {
  height: 1px;
  background: #F0EDE8;
  margin: 16px 0;
}

/* ═══════════════════════════════════════════════════════════
   SCROLLBAR SUTIL
═══════════════════════════════════════════════════════════ */
::-webkit-scrollbar { width: 5px; height: 5px; }
::-webkit-scrollbar-track { background: transparent; }
::-webkit-scrollbar-thumb { background: var(--color-tierra-200); border-radius: 999px; }
::-webkit-scrollbar-thumb:hover { background: var(--color-tierra-300); }

"@ | Set-Content -Path "src\styles\globals.css" -Encoding UTF8

Write-Host "  src\types\index.ts" -ForegroundColor Gray
@"
// ── Roles ─────────────────────────────────────────────────────
export type RolUsuario = 'admin' | 'operario' | 'usuario' | 'cliente'

/**
 * Matriz de permisos por rol
 * admin    → acceso total
 * operario → pedidos, produccion, avanzar etapas, asignar maquinas
 * usuario  → pedidos, produccion (lectura), reportes, asignar maquinas
 * cliente  → solo sus pedidos (lectura)
 */
export const PERMISOS: Record<RolUsuario, Record<string, boolean>> = {
  admin: {
    verDashboard:       true,
    verTodosPedidos:    true,
    crearPedidos:       true,
    avanzarEtapas:      true,
    asignarMaquinas:    true,
    verProduccion:      true,
    verReportes:        true,
    gestionarUsuarios:  true,
    verConfiguracion:   true,
  },
  operario: {
    verDashboard:       true,
    verTodosPedidos:    true,
    crearPedidos:       true,
    avanzarEtapas:      true,
    asignarMaquinas:    true,
    verProduccion:      true,
    verReportes:        false,
    gestionarUsuarios:  false,
    verConfiguracion:   false,
  },
  usuario: {
    verDashboard:       true,
    verTodosPedidos:    true,
    crearPedidos:       true,
    avanzarEtapas:      false,
    asignarMaquinas:    true,
    verProduccion:      true,   // solo lectura
    verReportes:        true,
    gestionarUsuarios:  false,
    verConfiguracion:   false,
  },
  cliente: {
    verDashboard:       true,   // limitado — solo sus pedidos
    verTodosPedidos:    false,  // solo los propios
    crearPedidos:       false,  // próximamente
    avanzarEtapas:      false,
    asignarMaquinas:    false,
    verProduccion:      false,
    verReportes:        false,
    gestionarUsuarios:  false,
    verConfiguracion:   false,
  },
}

export const tienPermiso = (rol: RolUsuario, permiso: string): boolean =>
  PERMISOS[rol]?.[permiso] ?? false

// ── Usuario ───────────────────────────────────────────────────
export interface Usuario {
  uid:                 string
  email:               string
  nombre:              string
  rol:                 RolUsuario
  activo:              boolean
  mustChangePassword:  boolean
  creadoEn:            Date
  ultimoAcceso?:       Date
  // v2.0: password almacenada con esquema PBKDF2+AES+HMAC
  passwordStored?: {
    hash:    string
    salt:    string
    hmac:    string
    version: number   // 1 = temporal (solo SEED_A), 2 = completo
  }
}

// ── Etapas ────────────────────────────────────────────────────
export type NombreEtapa =
  | 'ingreso_pedido'
  | 'preparado'
  | 'pre_produccion'
  | 'impresion'
  | 'encuadernacion'
  | 'remito_factura'
  | 'entregado'

export type TipoSubPedido = 'interior' | 'tapa' | 'unico'

export interface EtapaRegistro {
  id:               string
  nombre:           NombreEtapa
  fechaInicio:      Date
  fechaFin?:        Date
  duracionMinutos?: number
  usuarioUid:       string
  usuarioNombre:    string
  maquinaId?:       string
  maquinaNombre?:   string
  notas?:           string
  alertaActiva:     boolean
  sinReferencia:    boolean
}

// ── Sub-pedido ────────────────────────────────────────────────
export interface SubPedido {
  id:           string
  pedidoId:     string
  tipo:         TipoSubPedido
  etapaActual:  NombreEtapa
  maquinaId?:   string
  maquinaNombre?: string
  cantidad:     number
  etapas:       EtapaRegistro[]
  fechaInicio:  Date
  fechaFin?:    Date
  completado:   boolean
  notas?:       string
}

// ── Medidas ───────────────────────────────────────────────────
export interface Medidas {
  altoMm:  number
  anchoMm: number
}

// ── Producto ──────────────────────────────────────────────────
export type ClaseProducto = 'libro' | 'revista' | 'folleto' | 'catalogo' | 'cuaderno' | 'otro'
export type TamañoProducto = 'pequeño' | 'mediano' | 'grande'
export type RangoCantidad  = 'bajo' | 'medio' | 'alto'

// ── Pedido ────────────────────────────────────────────────────
export type EstadoPedido = 'borrador' | 'en_proceso' | 'pausado' | 'entregado' | 'cancelado'

export interface Pedido {
  id:                    string
  numeroPedido:          string
  clienteUid:            string
  clienteNombre:         string
  descripcion:           string
  claseProducto:         ClaseProducto
  medidas:               Medidas
  cantidadOriginal:      number
  mermaProcentaje:       number
  cantidadAjustada:      number
  tieneInteriorYTapa:    boolean
  subPedidos:            SubPedido[]
  estado:                EstadoPedido
  etapaActual:           NombreEtapa
  fechaIngreso:          Date
  fechaEstimadaEntrega:  Date
  fechaRealEntrega?:     Date
  creadoPor:             string
  actualizadoEn:         Date
  observaciones?:        string
  archivosRef?:          string[]
  // Máquinas asignadas por sub-tipo
  maquinaInteriorId?:    string
  maquinaInteriorNombre?: string
  maquinaTapaId?:        string
  maquinaTapaNombre?:    string
}

// ── Máquina ───────────────────────────────────────────────────
export type TipoMaquina = 'impresion' | 'encuadernacion' | 'pre_produccion' | 'mixta'

export interface Maquina {
  id:              string
  nombre:          string
  tipo:            TipoMaquina
  capacidadDiaria: number
  pedidosActivos:  string[]
  activa:          boolean
  notas?:          string
}

// ── Alerta ────────────────────────────────────────────────────
export interface Alerta {
  id:                    string
  pedidoId:              string
  subPedidoId?:          string
  numeroPedido:          string
  etapa:                 NombreEtapa
  tiempoRealMinutos:     number
  tiempoPromedioMinutos: number
  factorSuperado:        number
  creadaEn:              Date
  resuelta:              boolean
}

// ── Configuración ─────────────────────────────────────────────
export interface ConfigAlertas {
  muestrasMinimas: number
  factorAlerta:    number
  activado:        boolean
}

export interface ConfigMerma {
  libro:    number
  revista:  number
  folleto:  number
  catalogo: number
  cuaderno: number
  otro:     number
}

export interface AppConfig {
  nombreEmpresa: string
  zonaHoraria:   string
  alertas:       ConfigAlertas
  merma:         ConfigMerma
}

"@ | Set-Content -Path "src\types\index.ts" -Encoding UTF8

Write-Host "  src\utils\cn.ts" -ForegroundColor Gray
@"
import { clsx, type ClassValue } from 'clsx'
import { twMerge } from 'tailwind-merge'

export const cn = (...inputs: ClassValue[]) => twMerge(clsx(inputs))

"@ | Set-Content -Path "src\utils\cn.ts" -Encoding UTF8

Write-Host "  src\utils\etapaValidacion.ts" -ForegroundColor Gray
@"
/**
 * etapaValidacion.ts — v1.0.0
 * Validaciones para el avance de etapas en el flujo de producción.
 *
 * Reglas:
 * 1. No se puede iniciar una etapa si la anterior no tiene fechaFin
 * 2. No se puede avanzar si la etapa actual no tiene fechaInicio
 * 3. Las etapas de impresion/encuadernacion requieren maquina asignada
 * 4. Sub-pedidos interior y tapa se validan independientemente
 * 5. No se puede avanzar si ya es la etapa final (entregado)
 */

import { ETAPAS, getEtapa, getSiguienteEtapa } from '@config/etapas.config'
import type { EtapaRegistro, NombreEtapa, SubPedido, Pedido } from '@/types'

export interface ResultadoValidacion {
  valido:   boolean
  mensaje:  string
  detalle?: string
}

// ── Validar si se puede INICIAR una etapa ────────────────────
export const puedeIniciarEtapa = (
  nombreEtapa:  NombreEtapa,
  etapasReg:    EtapaRegistro[],
): ResultadoValidacion => {
  const cfg    = getEtapa(nombreEtapa)
  const orden  = cfg.orden

  // Primera etapa — siempre se puede iniciar
  if (orden === 1) return { valido: true, mensaje: '' }

  // Buscar etapa anterior
  const anterior = ETAPAS.find(e => e.orden === orden - 1)
  if (!anterior) return { valido: true, mensaje: '' }

  const regAnterior = etapasReg.find(e => e.nombre === anterior.nombre)

  if (!regAnterior) {
    return {
      valido:  false,
      mensaje: ``No se puede iniciar "`${cfg.label}"``,
      detalle: ``La etapa "`${anterior.label}" aún no fue iniciada``,
    }
  }

  if (!regAnterior.fechaFin) {
    return {
      valido:  false,
      mensaje: ``No se puede iniciar "`${cfg.label}"``,
      detalle: ``La etapa "`${anterior.label}" no ha sido completada todavía. Finalizala antes de continuar.``,
    }
  }

  return { valido: true, mensaje: '' }
}

// ── Validar si se puede AVANZAR desde la etapa actual ────────
export const puedeAvanzarDesde = (
  etapaActual:  NombreEtapa,
  etapasReg:    EtapaRegistro[],
  maquinaId?:   string,
): ResultadoValidacion => {
  const cfg       = getEtapa(etapaActual)
  const siguiente = getSiguienteEtapa(etapaActual)

  // Ya es la última etapa
  if (!siguiente || etapaActual === 'entregado') {
    return { valido: false, mensaje: 'Este pedido ya fue entregado' }
  }

  // Buscar registro de la etapa actual
  const regActual = etapasReg.find(e => e.nombre === etapaActual)

  if (!regActual) {
    return {
      valido:  false,
      mensaje: ``La etapa "`${cfg.label}" no fue iniciada``,
      detalle: 'Debes iniciar la etapa actual antes de avanzar',
    }
  }

  if (!regActual.fechaInicio) {
    return {
      valido:  false,
      mensaje: ``La etapa "`${cfg.label}" no tiene fecha de inicio``,
      detalle: 'La etapa debe ser iniciada formalmente antes de poder avanzar',
    }
  }

  // Validar maquina si la etapa la requiere
  if (cfg.requiereMaquina && !maquinaId && !regActual.maquinaId) {
    return {
      valido:  false,
      mensaje: ``La etapa "`${cfg.label}" requiere una máquina asignada``,
      detalle: 'Asigná una máquina antes de avanzar a la siguiente etapa',
    }
  }

  // La etapa actual ya fue completada (tiene fechaFin) — se puede avanzar
  if (regActual.fechaFin) {
    return { valido: true, mensaje: '' }
  }

  // La etapa actual está en curso — confirmar que quieren finalizarla
  return {
    valido:  true,
    mensaje: ``¿Confirmar finalización de "`${cfg.label}" y avance a "`${getEtapa(siguiente).label}"?``,
    detalle: 'Esta acción registrará la fecha de fin de la etapa actual y comenzará la siguiente',
  }
}

// ── Validar sub-pedido completo ───────────────────────────────
export const validarSubPedido = (
  sub: SubPedido,
): ResultadoValidacion => {
  return puedeAvanzarDesde(
    sub.etapaActual,
    sub.etapas,
    sub.maquinaId,
  )
}

// ── Validar pedido simple (sin interior/tapa) ─────────────────
export const validarPedidoSimple = (
  pedido: Pedido,
): ResultadoValidacion => {
  // Para pedidos simples usamos las etapas del primer subPedido
  // o reconstruimos desde el estado del pedido
  const regSimuladas: EtapaRegistro[] = []
  const etapaActualOrden = getEtapa(pedido.etapaActual).orden

  // Verificar que tiene fechaIngreso (etapa 1 iniciada)
  if (!pedido.fechaIngreso) {
    return {
      valido:  false,
      mensaje: 'El pedido no tiene fecha de ingreso registrada',
      detalle: 'Verifica la integridad del pedido',
    }
  }

  if (pedido.etapaActual === 'entregado') {
    return { valido: false, mensaje: 'Este pedido ya fue entregado' }
  }

  const cfg       = getEtapa(pedido.etapaActual)
  const siguiente = getSiguienteEtapa(pedido.etapaActual)

  if (!siguiente) {
    return { valido: false, mensaje: 'No hay siguiente etapa disponible' }
  }

  // Para impresion/encuadernacion verificar maquina
  if (cfg.requiereMaquina) {
    const tieneMaquina = pedido.tieneInteriorYTapa
      ? (pedido.maquinaInteriorId || pedido.maquinaTapaId)
      : true // pedidos simples sin subpedidos no requieren validacion de maquina aqui
    if (!tieneMaquina) {
      return {
        valido:  false,
        mensaje: ``La etapa "`${cfg.label}" requiere máquinas asignadas``,
        detalle: 'Asigná máquina a Interior y Tapa antes de avanzar',
      }
    }
  }

  return {
    valido:  true,
    mensaje: ``¿Confirmar avance a "`${getEtapa(siguiente).label}"?``,
    detalle: ``Esto registrará la finalización de "`${cfg.label}" con la fecha y hora actuales``,
  }
}

"@ | Set-Content -Path "src\utils\etapaValidacion.ts" -Encoding UTF8

Write-Host "  src\utils\fecha.ts" -ForegroundColor Gray
@"
import { format, formatDistance, differenceInMinutes, isAfter } from 'date-fns'
import { es } from 'date-fns/locale'

export const fFecha = (d: Date) =>
  format(d, 'dd/MM/yyyy', { locale: es })

export const fFechaHora = (d: Date) =>
  format(d, 'dd/MM/yyyy HH:mm', { locale: es })

export const fHora = (d: Date) =>
  format(d, 'HH:mm', { locale: es })

export const fRelativa = (d: Date) =>
  formatDistance(d, new Date(), { addSuffix: true, locale: es })

export const diffMinutos = (desde: Date, hasta: Date = new Date()) =>
  differenceInMinutes(hasta, desde)

export const diffHorasTexto = (minutos: number): string => {
  if (minutos < 60) return ```${minutos}m``
  const h = Math.floor(minutos / 60)
  const m = minutos % 60
  return m > 0 ? ```${h}h `${m}m`` : ```${h}h``
}

export const progresoTiempo = (inicio: Date, estimado: Date): number => {
  const total = differenceInMinutes(estimado, inicio)
  const transcurrido = differenceInMinutes(new Date(), inicio)
  if (total <= 0) return 100
  return Math.min(Math.round((transcurrido / total) * 100), 100)
}

export const estaVencido = (estimado: Date): boolean =>
  isAfter(new Date(), estimado)

export const hoy = (): string => format(new Date(), 'yyyy-MM-dd')

"@ | Set-Content -Path "src\utils\fecha.ts" -Encoding UTF8

Write-Host "  src\utils\pedido.ts" -ForegroundColor Gray
@"
import type { ClaseProducto } from '@/types'
import { APP_CONFIG } from '@/config/app.config'

export const calcularCantidadAjustada = (
  cantidad: number,
  clase: ClaseProducto,
  mermaManual?: number,
): { merma: number; ajustada: number } => {
  const pct = mermaManual ?? APP_CONFIG.merma[clase] ?? APP_CONFIG.merma.otro
  const merma = Math.ceil((cantidad * pct) / 100)
  return { merma, ajustada: cantidad + merma }
}

let contadorLocal = 44

export const generarNumeroPedido = (): string => {
  const anio = new Date().getFullYear()
  const num  = String(contadorLocal++).padStart(4, '0')
  return ``P-`${anio}-`${num}``
}

export const formatearMedidas = (alto: number, ancho: number): string =>
  ```${alto} × `${ancho} mm``

"@ | Set-Content -Path "src\utils\pedido.ts" -Encoding UTF8

Write-Host "  src\vite-env.d.ts" -ForegroundColor Gray
@"
/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_FIREBASE_API_KEY:             string
  readonly VITE_FIREBASE_AUTH_DOMAIN:         string
  readonly VITE_FIREBASE_PROJECT_ID:          string
  readonly VITE_FIREBASE_STORAGE_BUCKET:      string
  readonly VITE_FIREBASE_MESSAGING_SENDER_ID: string
  readonly VITE_FIREBASE_APP_ID:              string
  readonly VITE_SEED_A:                       string
  readonly VITE_SEED_B:                       string
  readonly VITE_SEED_C:                       string
  readonly VITE_APP_NAME:                     string
  readonly VITE_APP_VERSION:                  string
  readonly VITE_APP_ENV:                      string
  readonly VITE_APP_MODE:                     'demo' | 'prod'
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}

"@ | Set-Content -Path "src\vite-env.d.ts" -Encoding UTF8

Write-Host "  tsconfig.json" -ForegroundColor Gray
@"
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "types": ["node"],
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"],
      "@components/*": ["src/components/*"],
      "@modules/*": ["src/modules/*"],
      "@services/*": ["src/services/*"],
      "@hooks/*": ["src/hooks/*"],
      "@utils/*": ["src/utils/*"],
      "@context/*": ["src/context/*"],
      "@types/*": ["src/types/*"],
      "@config/*": ["src/config/*"],
      "@mock/*": ["src/mock/*"]
    },
    "strict": true,
    "noUnusedLocals": false,
    "noUnusedParameters": false,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src", "vite.config.ts"]
}

"@ | Set-Content -Path "tsconfig.json" -Encoding UTF8

Write-Host "  vite.config.ts" -ForegroundColor Gray
@"
import path from 'path'
import { fileURLToPath } from 'url'
import tailwindcss from '@tailwindcss/vite'
import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@components': path.resolve(__dirname, './src/components'),
      '@modules': path.resolve(__dirname, './src/modules'),
      '@services': path.resolve(__dirname, './src/services'),
      '@hooks': path.resolve(__dirname, './src/hooks'),
      '@utils': path.resolve(__dirname, './src/utils'),
      '@context': path.resolve(__dirname, './src/context'),
      '@types': path.resolve(__dirname, './src/types'),
      '@config': path.resolve(__dirname, './src/config'),
      '@mock': path.resolve(__dirname, './src/mock'),
    },
  },
  server: {
    port: 5173,
    open: true,
  },
})

"@ | Set-Content -Path "vite.config.ts" -Encoding UTF8

Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host " 49 archivos creados exitosamente" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "PROXIMOS PASOS:" -ForegroundColor Cyan
Write-Host "  1. npm install                  instalar dependencias" -ForegroundColor Yellow
Write-Host "  2. copy .env.example .env       crear archivo de entorno" -ForegroundColor Yellow
Write-Host "  3. npm run dev                  levantar servidor" -ForegroundColor Yellow
Write-Host ""
Write-Host "App en: http://localhost:5173" -ForegroundColor Cyan
Write-Host "Demo:   demo@imprenta.com / cualquier password" -ForegroundColor Cyan
Write-Host ""