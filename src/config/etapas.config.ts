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