import { useState, useEffect } from 'react';
import { pedidoService } from '../services/pedidoService';
import { Pedido } from '../types';

export const usePedidos = () => {
  const [pedidos, setPedidos] = useState<Pedido[]>([]);

  useEffect(() => {
    pedidoService.obtenerPedidos().then(data => setPedidos(data));
  }, []);

  return { pedidos };
};