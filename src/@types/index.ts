// Tipos principales del sistema IMPRENTA

export type UserRole = 'admin' | 'operario' | 'cliente';

export interface Usuario {
  id: string;
  email: string;
  nombre: string;
  rol: UserRole;
  passwordEncrypted: string;
  mustChange: boolean;
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

export type SubProducto = 'interior' | 'tapa';

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

export interface Pedido {
  id: string;
  numeroPedido: string;
  clienteId: string;
  clienteNombre: string;
  descripcion: string;
  cantidadOriginal: number;
  cantidadAjustada: number;
  fechaEstimadaEntrega: Date;
  fechaRealEntrega: Date | null;
  estado: 'pendiente' | 'en_proceso' | 'completado' | 'entregado';
  etapas: EtapasPedido;
  observaciones: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface Maquina {
  id: string;
  nombre: string;
  tipo: 'impresion' | 'encuadernacion' | 'preparacion' | 'preProduccion';
  activa: boolean;
}

export interface Alerta {
  id: string;
  pedidoId: string;
  etapa: EtapaNombre | SubProducto;
  tipo: 'retraso' | 'proxima_entrega' | 'merma_alta';
  mensaje: string;
  leida: boolean;
  createdAt: Date;
}