import {
  collection,
  doc,
  getDoc,
  getDocs,
  addDoc,
  updateDoc,
  query,
  where,
  orderBy,
  serverTimestamp,
  Timestamp
} from 'firebase/firestore';
import { db } from './firebase';

// ─── REFERENCIAS DE COLECCIONES REALES ──────────────────────────────
const pedidosRef = collection(db, 'pedidos');
const usuariosRef = collection(db, 'usuarios');
const alertasRef = collection(db, 'alertas');

// ─── BANCO DE DATOS MOCK (ENTORNO DEMO EN MEMORIA) ─────────────────
let mockPedidos = [
  { id: 'PED-001', clienteId: 'CLI-10', clienteNombre: 'Editorial Sudestada', descripcion: 'Libros Revistas A4', cantidadOriginal: 1000, cantidadAjustada: 980, estado: 'en_proceso', etapaActual: 'impresion', maquinaAsignada: 'Offset Heidel', createdAt: new Date(Date.now() - 86400000), fechaEstimadaEntrega: new Date(Date.now() + 172800000) },
  { id: 'PED-002', clienteId: 'CLI-11', clienteNombre: 'Packaging Express', descripcion: 'Cajas de Cartón Kraft', cantidadOriginal: 5000, cantidadAjustada: 5000, estado: 'pendiente', etapaActual: 'preprensa', maquinaAsignada: 'CtP Agfa', createdAt: new Date(), fechaEstimadaEntrega: new Date(Date.now() + 345600000) },
  { id: 'PED-003', clienteId: 'CLI-10', clienteNombre: 'Editorial Sudestada', descripcion: 'Folletería Institucional', cantidadOriginal: 2500, cantidadAjustada: 2400, estado: 'completado', etapaActual: 'encuadernacion', maquinaAsignada: 'Abrochadora Müller', createdAt: new Date(Date.now() - 172800000), fechaEstimadaEntrega: new Date() }
];

let mockUsuarios = [
  { id: 'USR-01', nombre: 'Carlos Mendoza', email: 'admin@demo.com', role: 'ADMINISTRADOR', rol: 'ADMINISTRADOR', activo: true },
  { id: 'USR-02', nombre: 'Juan Operario', email: 'operario@demo.com', role: 'OPERARIO', rol: 'OPERARIO', activo: true },
  { id: 'CLI-10', nombre: 'Editorial Sudestada', email: 'sudestada@demo.com', role: 'cliente', rol: 'cliente', activo: true },
  { id: 'CLI-11', nombre: 'Packaging Express', email: 'packaging@demo.com', role: 'cliente', rol: 'cliente', activo: true }
];

let mockAlertas = [
  { id: 'ALT-01', tipo: 'critica', mensaje: 'Falta de papel Ilustración 150g en guillotina.', leida: false, createdAt: new Date() },
  { id: 'ALT-02', tipo: 'advertencia', mensaje: 'Máquina Offset requiere mantenimiento preventivo.', leida: false, createdAt: new Date(Date.now() - 3600000) }
];

// Auxiliar para determinar si la sesión actual activa es Demo o Cloud Real
const esModoDemo = () => {
  const session = localStorage.getItem('imprenta_session');
  if (!session) return true; 
  return JSON.parse(session).isDemo === true;
};

// ─── SECCIÓN: USUARIOS ──────────────────────────────────────────────
export const getUsuario = async (id) => {
  if (esModoDemo()) {
    return mockUsuarios.find(u => u.id === id) || null;
  }
  const docSnap = await getDoc(doc(db, 'usuarios', id));
  if (docSnap.exists()) {
    return { id: docSnap.id, ...docSnap.data() };
  }
  return null;
};

export const getUsuarios = async () => {
  if (esModoDemo()) return [...mockUsuarios];
  const q = query(usuariosRef, orderBy('nombre', 'asc'));
  const querySnapshot = await getDocs(q);
  return querySnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
};

export const getClientes = async () => {
  if (esModoDemo()) return mockUsuarios.filter(u => u.role === 'cliente' || u.rol === 'cliente');
  const q = query(usuariosRef, where('rol', '==', 'cliente'), orderBy('nombre', 'asc'));
  const querySnapshot = await getDocs(q);
  return querySnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
};

export const crearUsuario = async (usuario) => {
  if (esModoDemo()) {
    const nuevo = { id: `USR-${Date.now()}`, ...usuario, activo: true, createdAt: new Date() };
    mockUsuarios.push(nuevo);
    return nuevo;
  }
  return await addDoc(usuariosRef, {
    ...usuario,
    activo: true,
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  });
};

// ─── SECCIÓN: PEDIDOS ──────────────────────────────────────────────
export const getPedidos = async (rol, clienteId) => {
  if (esModoDemo()) {
    let result = [...mockPedidos];
    if (rol === 'cliente' && clienteId) {
      result = result.filter(p => p.clienteId === clienteId);
    }
    return result.sort((a, b) => b.createdAt - a.createdAt);
  }

  let q = query(pedidosRef, orderBy('createdAt', 'desc'));
  if (rol === 'cliente' && clienteId) {
    q = query(pedidosRef, where('clienteId', '==', clienteId), orderBy('createdAt', 'desc'));
  }

  const querySnapshot = await getDocs(q);
  return querySnapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data(),
    createdAt: doc.data().createdAt instanceof Timestamp ? doc.data().createdAt.toDate() : new Date(),
    fechaEstimadaEntrega: doc.data().fechaEstimadaEntrega instanceof Timestamp ? doc.data().fechaEstimadaEntrega.toDate() : null,
  }));
};

export const crearPedido = async (pedido) => {
  if (esModoDemo()) {
    const nuevo = {
      id: `PED-${Math.floor(100 + Math.random() * 900)}`,
      ...pedido,
      estado: 'pendiente',
      createdAt: new Date(),
      updatedAt: new Date()
    };
    mockPedidos.push(nuevo);
    return nuevo;
  }
  return await addDoc(pedidosRef, {
    ...pedido,
    estado: 'pendiente',
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  });
};

export const agregarPedido = async (data) => {
  if (esModoDemo()) {
    const nuevo = {
      id: `PED-${Math.floor(100 + Math.random() * 900)}`,
      ...data,
      createdAt: new Date(),
      updatedAt: new Date()
    };
    mockPedidos.push(nuevo);
    return nuevo.id;
  }
  try {
    const docRef = await addDoc(pedidosRef, {
      ...data,
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
    });
    return docRef.id;
  } catch (error) {
    console.error("Error al crear el pedido:", error);
    throw error;
  }
};

export const actualizarPedido = async (id, data) => {
  if (esModoDemo()) {
    mockPedidos = mockPedidos.map(p => p.id === id ? { ...p, ...data, updatedAt: new Date() } : p);
    return true;
  }
  const docRef = doc(db, 'pedidos', id);
  return await updateDoc(docRef, {
    ...data,
    updatedAt: serverTimestamp(),
  });
};

// ─── SECCIÓN: ALERTAS ──────────────────────────────────────────────
export const getAlertas = async () => {
  if (esModoDemo()) return [...mockAlertas];
  try {
    const q = query(alertasRef, orderBy('createdAt', 'desc'));
    const querySnapshot = await getDocs(q);

    return querySnapshot.docs.map(doc => {
      const data = doc.data();
      return {
        id: doc.id,
        ...data,
        createdAt: data.createdAt instanceof Timestamp ? data.createdAt.toDate() : new Date(),
      };
    });
  } catch (error) {
    console.error("Error al obtener alertas:", error);
    return [];
  }
};

// ─── SECCIÓN: KPIs (DASHBOARD ENGINE) ────────────────────────────────
export const getKpis = async () => {
  const pedidos = await getPedidos();

  return {
    pedidosTotales: pedidos.length,
    pedidosPendientes: pedidos.filter(p => p.estado === 'pendiente').length,
    pedidosEnProceso: pedidos.filter(p => p.estado === 'en_proceso').length,
    pedidosCompletados: pedidos.filter(p => p.estado === 'completado').length,
    pedidosEntregados: pedidos.filter(p => p.estado === 'entregado').length,
    mermaTotal: pedidos.reduce((acc, p) => {
      const cantOrig = p.cantidadOriginal || 0;
      const cantAjust = p.cantidadAjustada !== undefined && p.cantidadAjustada !== null ? p.cantidadAjustada : cantOrig;
      return acc + (cantOrig - cantAjust);
    }, 0)
  };
};