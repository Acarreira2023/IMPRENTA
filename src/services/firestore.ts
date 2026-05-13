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
import { Pedido, Usuario, Maquina, KpiData, Alerta } from '../types/index';

// Referencias de colecciones
const pedidosRef = collection(db, 'pedidos');
const usuariosRef = collection(db, 'usuarios');
const alertasRef = collection(db, 'alertas');

// --- USUARIOS ---
export const getUsuario = async (id: string): Promise<Usuario | null> => {
  const docSnap = await getDoc(doc(db, 'usuarios', id));
  if (docSnap.exists()) {
    return { id: docSnap.id, ...docSnap.data() } as Usuario;
  }
  return null;
};

// --- PEDIDOS ---
export const getPedidos = async (rol?: string, clienteId?: string): Promise<Pedido[]> => {
  let q = query(pedidosRef, orderBy('createdAt', 'desc'));

  // Si es cliente, filtramos solo sus pedidos
  if (rol === 'cliente' && clienteId) {
    q = query(pedidosRef, where('clienteId', '==', clienteId), orderBy('createdAt', 'desc'));
  }

  const querySnapshot = await getDocs(q);
  return querySnapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data(),
    createdAt: (doc.data().createdAt as Timestamp)?.toDate(),
    fechaEstimadaEntrega: (doc.data().fechaEstimadaEntrega as Timestamp)?.toDate(),
  })) as Pedido[];
};

export const crearPedido = async (pedido: Partial<Pedido>) => {
  return await addDoc(pedidosRef, {
    ...pedido,
    estado: 'pendiente',
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  });
};

export const actualizarPedido = async (id: string, data: Partial<Pedido>) => {
  const docRef = doc(db, 'pedidos', id);
  return await updateDoc(docRef, {
    ...data,
    updatedAt: serverTimestamp(),
  });
};

export const agregarPedido = async (data: any) => {
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

// --- ALERTAS ---
export const getAlertas = async (): Promise<Alerta[]> => {
  try {
    // Asegura el orden descendente para ver lo más nuevo arriba
    const q = query(alertasRef, orderBy('createdAt', 'desc'));
    const querySnapshot = await getDocs(q);

    return querySnapshot.docs.map(doc => {
      const data = doc.data();

      return {
        id: doc.id,
        ...data,
        // Validación de seguridad: si createdAt no existe o falla, 
        // evita que la app rompa usando la fecha actual como fallback.
        createdAt: data.createdAt instanceof Timestamp 
          ? data.createdAt.toDate() 
          : new Date(),
      } as Alerta;
    });
  } catch (error) {
    console.error("Error al obtener alertas:", error);
    return []; // Retorna un array vacío para que la UI no rompa
  }
};

// --- KPIs (Lógica para el Dashboard) ---
export const getKpis = async (): Promise<KpiData> => {
  const pedidos = await getPedidos();

  return {
    pedidosTotales: pedidos.length,
    pedidosPendientes: pedidos.filter(p => p.estado === 'pendiente').length,
    pedidosEnProceso: pedidos.filter(p => p.estado === 'en_proceso').length,
    pedidosCompletados: pedidos.filter(p => p.estado === 'completado').length,
    pedidosEntregados: pedidos.filter(p => p.estado === 'entregado').length,
    // Merma: diferencia entre cantidad original y ajustada
    mermaTotal: pedidos.reduce((acc, p) => {
      const cantidadAjustada = p.cantidadAjustada ?? p.cantidadOriginal;
      return acc + (p.cantidadOriginal - cantidadAjustada);
    }, 0)
  };
};

// --- GESTIÓN DE USUARIOS (Agregar al final de firestore.ts) ---

export const getUsuarios = async (): Promise<Usuario[]> => {
  const q = query(usuariosRef, orderBy('nombre', 'asc'));
  const querySnapshot = await getDocs(q);
  return querySnapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
  })) as Usuario[];
};

export const crearUsuario = async (usuario: Partial<Usuario>) => {
  return await addDoc(usuariosRef, {
    ...usuario,
    activo: true,
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  });
};

// Función para obtener solo los clientes
export const getClientes = async (): Promise<Usuario[]> => {
  const q = query(
    usuariosRef,
    where('rol', '==', 'cliente'),
    orderBy('nombre', 'asc')
  );
  const querySnapshot = await getDocs(q);
  return querySnapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
  })) as Usuario[];
};