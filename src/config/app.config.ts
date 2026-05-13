import type { AppConfig } from '../types'

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