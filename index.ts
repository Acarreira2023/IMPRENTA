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