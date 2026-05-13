import type { Pedido, Maquina, Usuario, Alerta } from '../types';


// ── Usuarios mock ──────────────────────────────────────────────
export const MOCK_USUARIOS: Usuario[] = [
  {
    id: 'admin-001',
    email: 'admin@imprenta.com',
    nombre: 'Administrador',
    rol: 'admin',
    passwordEncrypted: 'hashed_password_1',
    mustChangePassword: false,
    activo: true,
    createdAt: new Date('2026-01-01'),
    updatedAt: new Date('2026-01-01'),
  },
  {
    id: 'op-001',
    email: 'operario@imprenta.com',
    nombre: 'Carlos Méndez',
    rol: 'operario',
    passwordEncrypted: 'hashed_password_2',
    mustChangePassword: false,
    activo: true,
    createdAt: new Date('2026-01-15'),
    updatedAt: new Date('2026-01-15'),
  },
  {
    id: 'op-002',
    email: 'operario2@imprenta.com',
    nombre: 'Laura Ramos',
    rol: 'operario',
    passwordEncrypted: 'hashed_password_3',
    mustChangePassword: false,
    activo: true,
    createdAt: new Date('2026-02-01'),
    updatedAt: new Date('2026-02-01'),
  },
  {
    id: 'usr-001',
    email: 'usuario@imprenta.com',
    nombre: 'Martín Suárez',
    rol: 'usuario',
    passwordEncrypted: 'hashed_password_4',
    mustChangePassword: false,
    activo: true,
    createdAt: new Date('2026-02-15'),
    updatedAt: new Date('2026-02-15'),
  },
  {
    id: 'cli-001',
    email: 'cliente@editorial.com',
    nombre: 'Editorial Sur S.A.',
    rol: 'cliente',
    clienteId: 'C-001',
    passwordEncrypted: 'hashed_password_5',
    mustChangePassword: false,
    activo: true,
    createdAt: new Date('2026-01-20'),
    updatedAt: new Date('2026-01-20'),
  },
  {
    id: 'demo-001',
    email: 'demo@imprenta.com',
    nombre: 'Usuario Demo',
    rol: 'admin',
    passwordEncrypted: 'hashed_password_6',
    mustChangePassword: false,
    activo: true,
    createdAt: new Date('2026-01-01'),
    updatedAt: new Date('2026-01-01'),
  }
];

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
  // Pedido 1: Revista
  {
    id: 'P-2026-0042', numeroPedido: 'P-2026-0042',
    clienteId: 'cli-001', clienteNombre: 'Editorial Sur S.A.',
    descripcion: 'Revista mensual N°48 — 200 páginas A4',
    claseProducto: 'revista',
    medidas: { altoMm: 297, anchoMm: 210 },
    cantidadOriginal: 2000, mermaProcentaje: 0.25, cantidadAjustada: 2005,
    tieneInteriorYTapa: true,
    maquinaInteriorId: 'maq-imp-01', maquinaInteriorNombre: 'Offset Heidelberg 01',
    subPedidos: [
      { id: 'P-2026-0042-I', pedidoId: 'P-2026-0042', tipo: 'interior', etapaActual: 'impresion', maquinaId: 'maq-imp-01', maquinaNombre: 'Offset Heidelberg 01', cantidad: 2005, etapas: [], fechaInicio: new Date('2026-04-24T08:00'), completado: false },
      { id: 'P-2026-0042-T', pedidoId: 'P-2026-0042', tipo: 'tapa', etapaActual: 'pre_produccion', cantidad: 2005, etapas: [], fechaInicio: new Date('2026-04-24T08:00'), completado: false }
    ],
    fechaEstimadaEntrega: new Date('2026-05-02T18:00'), fechaRealEntrega: null,
    estado: 'en_proceso', etapaActual: 'impresion', fechaIngreso: new Date('2026-04-24T08:00'),
    etapas: {
      ingresoPedido: { fecha: new Date(), usuarioId: 'admin-001' },
      preparado: { inicio: null, fin: null, usuarioId: null, maquinaId: null },
      preProduccion: { inicio: null, fin: null, usuarioId: null, maquinaId: null },
      impresion: { interior: { inicio: null, fin: null, usuarioId: null, maquinaId: null }, tapa: { inicio: null, fin: null, usuarioId: null, maquinaId: null } },
      encuadernacion: { interior: { inicio: null, fin: null, usuarioId: null, maquinaId: null }, tapa: { inicio: null, fin: null, usuarioId: null, maquinaId: null } },
      remitoFacturacion: { inicio: null, fin: null, usuarioId: null, maquinaId: null },
      entregado: { fecha: null, usuarioId: null }
    },
    creadoPor: 'admin-001', observaciones: 'Papel obra 90gr para interior',
    createdAt: new Date(), updatedAt: new Date('2026-04-29T16:00')
  },

  // Pedido 2: Catálogo
  {
    id: 'P-2026-0041', numeroPedido: 'P-2026-0041',
    clienteId: 'cli-002', clienteNombre: 'Librería Norma',
    descripcion: 'Catálogo temporada otoño — 48 páginas',
    claseProducto: 'catalogo',
    medidas: { altoMm: 210, anchoMm: 148 },
    cantidadOriginal: 500, mermaProcentaje: 0.20, cantidadAjustada: 501,
    tieneInteriorYTapa: true, subPedidos: [],
    fechaEstimadaEntrega: new Date('2026-04-30T18:00'), fechaRealEntrega: null,
    estado: 'en_proceso', etapaActual: 'encuadernacion', fechaIngreso: new Date('2026-04-20T09:00'),
    etapas: {
      ingresoPedido: { fecha: new Date(), usuarioId: 'admin-001' },
      preparado: { inicio: null, fin: null, usuarioId: null, maquinaId: null },
      preProduccion: { inicio: null, fin: null, usuarioId: null, maquinaId: null },
      impresion: { interior: { inicio: null, fin: null, usuarioId: null, maquinaId: null }, tapa: { inicio: null, fin: null, usuarioId: null, maquinaId: null } },
      encuadernacion: { interior: { inicio: null, fin: null, usuarioId: null, maquinaId: null }, tapa: { inicio: null, fin: null, usuarioId: null, maquinaId: null } },
      remitoFacturacion: { inicio: null, fin: null, usuarioId: null, maquinaId: null },
      entregado: { fecha: null, usuarioId: null }
    },
    creadoPor: 'admin-001', observaciones: '',
    createdAt: new Date(), updatedAt: new Date('2026-04-29T10:00')
  },

  // Pedido 3: Folleto (Entregado)
  {
    id: 'P-2026-0040', numeroPedido: 'P-2026-0040',
    clienteId: 'cli-003', clienteNombre: 'Municipalidad de Palermo',
    descripcion: 'Folletos informativos — 4 páginas A5',
    claseProducto: 'folleto',
    medidas: { altoMm: 148, anchoMm: 105 },
    cantidadOriginal: 5000, mermaProcentaje: 0.20, cantidadAjustada: 5010,
    tieneInteriorYTapa: false, subPedidos: [],
    fechaEstimadaEntrega: new Date('2026-04-25T18:00'), fechaRealEntrega: new Date('2026-04-25T14:30'),
    estado: 'entregado', etapaActual: 'entregado', fechaIngreso: new Date('2026-04-14T08:00'),
    etapas: {
      ingresoPedido: { fecha: new Date(), usuarioId: 'admin-001' },
      preparado: { inicio: null, fin: null, usuarioId: null, maquinaId: null },
      preProduccion: { inicio: null, fin: null, usuarioId: null, maquinaId: null },
      impresion: { interior: { inicio: null, fin: null, usuarioId: null, maquinaId: null }, tapa: { inicio: null, fin: null, usuarioId: null, maquinaId: null } },
      encuadernacion: { interior: { inicio: null, fin: null, usuarioId: null, maquinaId: null }, tapa: { inicio: null, fin: null, usuarioId: null, maquinaId: null } },
      remitoFacturacion: { inicio: null, fin: null, usuarioId: null, maquinaId: null },
      entregado: { fecha: new Date(), usuarioId: 'op-001' }
    },
    creadoPor: 'op-001', observaciones: '',
    createdAt: new Date(), updatedAt: new Date('2026-04-25T14:30')
  },

  // Pedido 4: Libro
  {
    id: 'P-2026-0039', numeroPedido: 'P-2026-0039',
    clienteId: 'cli-001', clienteNombre: 'Editorial Sur S.A.',
    descripcion: 'Libro "Historia del Río" — 320 páginas',
    claseProducto: 'libro',
    medidas: { altoMm: 230, anchoMm: 155 },
    cantidadOriginal: 1000, mermaProcentaje: 0.30, cantidadAjustada: 1003,
    tieneInteriorYTapa: true,
    maquinaInteriorId: 'maq-imp-01', maquinaInteriorNombre: 'Offset Heidelberg 01',
    maquinaTapaId: 'maq-enc-02', maquinaTapaNombre: 'Cosedora Fresadora 02',
    subPedidos: [],
    fechaEstimadaEntrega: new Date('2026-05-05T18:00'), fechaRealEntrega: null,
    estado: 'en_proceso', etapaActual: 'impresion', fechaIngreso: new Date('2026-04-22T10:00'),
    etapas: { 
      ingresoPedido: { fecha: new Date(), usuarioId: 'admin-001' },
      preparado: { inicio: null, fin: null, usuarioId: null, maquinaId: null },
      preProduccion: { inicio: null, fin: null, usuarioId: null, maquinaId: null },
      impresion: { interior: { inicio: null, fin: null, usuarioId: null, maquinaId: null }, tapa: { inicio: null, fin: null, usuarioId: null, maquinaId: null } },
      encuadernacion: { interior: { inicio: null, fin: null, usuarioId: null, maquinaId: null }, tapa: { inicio: null, fin: null, usuarioId: null, maquinaId: null } },
      remitoFacturacion: { inicio: null, fin: null, usuarioId: null, maquinaId: null },
      entregado: { fecha: null, usuarioId: null }
    },
    creadoPor: 'admin-001', observaciones: 'Papel ilustración 115gr',
    createdAt: new Date(), updatedAt: new Date('2026-04-28T11:00')
  },

  // Pedido 5: Recetarios
  {
    id: 'P-2026-0043', numeroPedido: 'P-2026-0043',
    clienteId: 'cli-004', clienteNombre: 'Farmacia Central',
    descripcion: 'Recetarios personalizados — A5',
    claseProducto: 'otro',
    medidas: { altoMm: 148, anchoMm: 105 },
    cantidadOriginal: 300, mermaProcentaje: 0.20, cantidadAjustada: 301,
    tieneInteriorYTapa: false, subPedidos: [],
    fechaEstimadaEntrega: new Date('2026-05-03T18:00'), fechaRealEntrega: null,
    estado: 'en_proceso', etapaActual: 'preparado', fechaIngreso: new Date('2026-04-29T09:00'),
    etapas: { 
      ingresoPedido: { fecha: new Date(), usuarioId: 'admin-001' },
      preparado: { inicio: new Date(), fin: null, usuarioId: 'op-002', maquinaId: null },
      preProduccion: { inicio: null, fin: null, usuarioId: null, maquinaId: null },
      impresion: { interior: { inicio: null, fin: null, usuarioId: null, maquinaId: null }, tapa: { inicio: null, fin: null, usuarioId: null, maquinaId: null } },
      encuadernacion: { interior: { inicio: null, fin: null, usuarioId: null, maquinaId: null }, tapa: { inicio: null, fin: null, usuarioId: null, maquinaId: null } },
      remitoFacturacion: { inicio: null, fin: null, usuarioId: null, maquinaId: null },
      entregado: { fecha: null, usuarioId: null }
    },
    creadoPor: 'op-002', observaciones: '',
    createdAt: new Date(), updatedAt: new Date('2026-04-29T09:30')
  }
];

// ── Alertas mock ───────────────────────────────────────────────
export const MOCK_ALERTAS: Alerta[] = [
  {
    id: 'alerta-001',
    pedidoId: 'P-2026-0041',
    mensaje: 'Atraso en encuadernación', // Campo obligatorio
    tipo: 'atraso',
    leida: false,
    createdAt: new Date('2026-04-29T15:00'),
  },
];

// ── Modo demo ──────────────────────────────────────────────────
export const MODO_DEMO = import.meta.env.VITE_APP_MODE === 'demo'
  || !import.meta.env.VITE_FIREBASE_API_KEY

export const MOCK_SESSION_DEMO = MOCK_USUARIOS.find(u => u.id === 'demo-001')!