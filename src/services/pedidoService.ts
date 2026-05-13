import { db } from './firebase';
import { collection, getDocs } from 'firebase/firestore';
import { MOCK_PEDIDOS } from '../mock/mockData';
import { Pedido } from '../types';

export const pedidoService = {
  async obtenerPedidos(): Promise<Pedido[]> {
    // Si estamos en modo DEMO, devolvemos los datos locales
    if (import.meta.env.VITE_APP_MODE === 'demo') {
      console.log('Modo Demo: Usando MOCK_PEDIDOS');
      return MOCK_PEDIDOS;
    }

    // Si no, llamamos a Firebase
    console.log('Modo Producción: Conectando a Firestore');
    const querySnapshot = await getDocs(collection(db, 'pedidos'));
    return querySnapshot.docs.map(doc => ({
      ...doc.data(),
      id: doc.id
    })) as Pedido[];
  }
};