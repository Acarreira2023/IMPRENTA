import { getPedidos } from './firestore';

/**
 * Servicio unificado de pedidos para desacoplar las vistas de la infraestructura.
 * Consume de forma transparente el motor híbrido (Demo en memoria / Firestore Real).
 */
export const pedidoService = {
  async obtenerPedidos(rol, clienteId) {
    try {
      // Se delega la lógica al hub central de firestore que ya discrimina el entorno
      return await getPedidos(rol, clienteId);
    } catch (error) {
      console.error("Error crítico en pedidoService.obtenerPedidos:", error);
      throw error;
    }
  }
};

export default pedidoService;