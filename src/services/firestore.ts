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
import { Pedido, Usuario, Maquina, KpiData } from '@types';

// Referencias de colecciones
const pedidosRef = collection(db, 'pedidos');
const usuariosRef = collection(db, 'usuarios');
const maquinasRef = collection(db, 'maquinas');

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

// --- KPIs (Para el Dashboard de Admin) ---
export const getKpis = async (): Promise<KpiData> => {
  const pedidos = await getPedidos();
  
  const totales = pedidos.length;
  const enProceso = pedidos.filter(p => p.estado === 'en_proceso').length;
  const completados = pedidos.filter(p => p.estado === 'completado').length;
  
  // Cálculo de merma simple
  const mermaTotal = pedidos.reduce((acc, p) => acc + (p.cantidadOriginal - (p.cantidadAjustada || p.cantidadOriginal)), 0);

  return {
    pedidosTotales: totales,
    pedidosEnProceso: enProceso,
    pedidosFinalizados: completados,
    mermaTotal: mermaTotal,
    eficiencia: totales > 0 ? Math.round((completados / totales) * 100) : 0
  };
};