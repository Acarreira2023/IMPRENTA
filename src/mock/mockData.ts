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