// Tipos principales del sistema IMPRENTA

export type UserRole = 'admin' | 'operario' | 'cliente' | 'usuario';
export type ClaseProducto = 'libro' | 'revista' | 'folleto' | 'catalogo' | 'cuaderno' | 'otro';
export type PedidoEstado = 'pendiente' | 'en_proceso' | 'completado' | 'entregado';
export type SubProducto = 'interior' | 'tapa';

export interface Usuario {
  id: string;
  email: string;
  nombre: string;
  rol: UserRole;
  passwordEncrypted: string;
  mustChangePassword: boolean;
  clienteId?: string;
  activo: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export type EtapaNombre =
  | 'ingresoPedido'
  | 'preparado'
  | 'preProduccion'
  | 'impresion'
  | 'encuadernacion'
  | 'remitoFacturacion'
  | 'entregado';


export interface EtapaBase {
  inicio: Date | null;
  fin: Date | null;
  usuarioId: string | null;
  maquinaId: string | null;
}

export interface EtapaConSubProductos {
  interior: EtapaBase;
  tapa: EtapaBase;
}

export interface EtapasPedido {
  ingresoPedido: { fecha: Date | null; usuarioId: string | null };
  preparado: EtapaBase;
  preProduccion: EtapaBase;
  impresion: EtapaConSubProductos;
  encuadernacion: EtapaConSubProductos;
  remitoFacturacion: EtapaBase;
  entregado: { fecha: Date | null; usuarioId: string | null };
}

export interface EtapaDetalle {
  id: string;
  nombre: string;
  fechaInicio: Date;
  fechaFin?: Date;
  duracionMinutos?: number;
  usuarioUid: string;
  usuarioNombre: string;
  maquinaId?: string;
  maquinaNombre?: string;
  alertaActiva: boolean;
  sinReferencia: boolean;
}

export interface SubPedido {
  id: string;
  pedidoId: string;
  tipo: 'interior' | 'tapa';
  etapaActual: string;
  maquinaId?: string;
  maquinaNombre?: string;
  cantidad: number;
  etapas: EtapaDetalle[];
  fechaInicio: Date;
  completado: boolean;
}

export interface Pedido {
  id: string;
  numeroPedido: string;
  clienteId: string;
  clienteNombre: string;
  descripcion: string;
  claseProducto: ClaseProducto;
  medidas: { altoMm: number; anchoMm: number };
  cantidadOriginal: number;
  mermaProcentaje: number;
  cantidadAjustada: number;
  tieneInteriorYTapa: boolean;
  maquinaInteriorId?: string;
  maquinaInteriorNombre?: string;
  maquinaTapaId?: string;
  maquinaTapaNombre?: string;
  subPedidos: SubPedido[];
  fechaEstimadaEntrega: Date;
  fechaRealEntrega: Date | null;
  estado: PedidoEstado;
  etapas: EtapasPedido;
  etapaActual: string;
  fechaIngreso: Date;
  creadoPor: string;
  observaciones: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface Maquina {
  id: string;
  nombre: string;
  capacidadDiaria: number;
  pedidosActivos: string[];
  tipo: 'impresion' | 'encuadernacion' | 'preparacion' | 'preProduccion';
  activa: boolean;
  notas?: string;
}

export interface Alerta {
  id: string;
  pedidoId: string;
  etapa?: EtapaNombre | SubProducto; // Opcional para compatibilidad
  mensaje: string;
  tipo: 'urgente' | 'atraso' | 'merma' | 'retraso' | 'proxima_entrega' | 'merma_alta'; 
  leida: boolean;
  createdAt: Date;
}

export interface KpiData {
  pedidosTotales: number;
  pedidosPendientes: number;
  pedidosEnProceso: number;
  pedidosCompletados: number;
  pedidosEntregados: number;
  mermaTotal: number;
}

export interface AppConfig {
  nombreEmpresa: string;
  zonaHoraria: string;
  alertas: {
    muestrasMinimas: number;
    factorAlerta: number;
    activado: boolean;
  };
  merma: {
    libro: number;
    revista: number;
    folleto: number;
    catalogo: number;
    cuaderno: number;
    otro: number;
  };
}