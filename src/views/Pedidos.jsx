import React, { useState, useEffect } from 'react';
import FormularioPedido from './FormularioPedido.jsx';
import { useAuth } from '../context/AuthContext.jsx';
import { pedidoService } from '../services/pedidoService.js';
import { agregarPedido, actualizarPedido } from '../services/firestore.js';

export default function Pedidos() {
  const { user } = useAuth();
  const [orders, setOrders] = useState([]);
  const [isEditing, setIsEditing] = useState(false);
  const [currentOrder, setCurrentOrder] = useState(null);
  const [loading, setLoading] = useState(true);

  // Función para sincronizar la grilla de producción
  const cargarPedidosPlanta = async () => {
    try {
      setLoading(true);
      // El servicio abstrae de forma transparente si consume la simulación local o Firebase Cloud
      const data = await pedidoService.obtenerPedidos(user?.role, user?.uid);
      setOrders(data);
    } catch (error) {
      console.error("Error al recuperar la nómina de pedidos:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    cargarPedidosPlanta();
  }, [user]); // Se recarga automáticamente si el navbar cambia entre Demo y Real

  const handleOpenCreate = () => {
    setCurrentOrder(null);
    setIsEditing(true);
  };

  const handleSave = async (savedOrder) => {
    try {
      if (currentOrder) {
        // Modo Edición: Actualizar registro existente
        await actualizarPedido(savedOrder.id, savedOrder);
      } else {
        // Modo Alta: Insertar nueva ficha técnica
        await agregarPedido(savedOrder);
      }
      setIsEditing(false);
      await cargarPedidosPlanta(); // Refrescar la grilla de datos de inmediato
    } catch (error) {
      console.error("Error al persistir cambios en el pedido:", error);
      alert("Error al intentar guardar el pedido en el entorno de datos actual.");
    }
  };

  // Función auxiliar para formatear los tags visuales de los estados industriales
  const getBadgeStyle = (estado) => {
    switch (estado?.toLowerCase()) {
      case 'pendiente': return 'bg-slate-100 text-slate-700 border-slate-200';
      case 'en_proceso': return 'bg-amber-100 text-amber-800 border-amber-200';
      case 'completado': return 'bg-emerald-100 text-emerald-800 border-emerald-200';
      case 'entregado': return 'bg-blue-100 text-blue-800 border-blue-200';
      default: return 'bg-slate-100 text-slate-600 border-slate-200';
    }
  };

  if (loading) {
    return <p className="text-xs font-mono p-6 text-slate-400 animate-pulse">Sincronizando entorno seguro de datos...</p>;
  }

  return (
    <div className="space-y-6 animate-fadeIn">
      {/* Indicador contextual de Sandbox / Producción */}
      <div className={`p-3 rounded-xl border flex justify-between items-center ${user?.isDemo ? 'bg-amber-500/10 border-amber-500/20 text-amber-800' : 'bg-emerald-500/10 border-emerald-500/20 text-emerald-800'}`}>
        <span className="text-xs font-bold">
          {user?.isDemo ? '⚠️ MÓDULO SANDBOX (DEMO EN MEMORIA)' : '🟢 ENTORNO DE PRODUCCIÓN CLOUD FIRESTORE'}
        </span>
      </div>

      {/* Título de Sección y Botón de Altas */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-xl md:text-2xl font-bold text-slate-900">Gestión de Pedidos</h1>
          <p className="text-xs text-slate-500">Administración de fichas técnicas y órdenes de impresión</p>
        </div>
        {user?.role === 'ADMINISTRADOR' && (
          <button 
            onClick={handleOpenCreate} 
            className="px-4 py-2 bg-orange-500 text-white font-bold text-xs rounded-xl shadow-sm hover:bg-orange-600 transition-colors"
          >
            + Registrar Orden
          </button>
        )}
      </div>

      {isEditing ? (
        <FormularioPedido 
          order={currentOrder} 
          onSave={handleSave} 
          onCancel={() => setIsEditing(false)} 
        />
      ) : (
        /* Grilla Industrial de Pedidos */
        <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse text-xs">
              <thead>
                <tr className="bg-slate-50 border-b border-slate-200 text-[10px] font-bold text-slate-500 uppercase tracking-wider">
                  <th className="p-4">ID</th>
                  <th className="p-4">Cliente</th>
                  <th className="p-4">Trabajo / Descripción</th>
                  <th className="p-4">Tirada</th>
                  <th className="p-4">Estado</th>
                  {user?.role === 'ADMINISTRADOR' && <th className="p-4 text-center">Acción</th>}
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {orders.length === 0 ? (
                  <tr>
                    <td colSpan={user?.role === 'ADMINISTRADOR' ? 6 : 5} className="p-8 text-center text-slate-400 italic">
                      No se encontraron órdenes de producción registradas en este entorno.
                    </td>
                  </tr>
                ) : (
                  orders.map(order => (
                    <tr key={order.id} className="hover:bg-slate-50/50 transition-colors">
                      <td className="p-4 font-mono font-bold text-orange-500">{order.id}</td>
                      <td className="p-4 font-semibold text-slate-800">{order.clienteNombre || 'Sin identificar'}</td>
                      <td className="p-4 text-slate-600">{order.descripcion}</td>
                      <td className="p-4 font-mono text-slate-700">
                        {(order.cantidadOriginal || 0).toLocaleString()} un.
                      </td>
                      <td className="p-4">
                        <span className={`px-2 py-0.5 rounded-md font-bold text-[10px] border ${getBadgeStyle(order.estado)}`}>
                          {order.estado ? order.estado.toUpperCase().replace('_', ' ') : 'PENDIENTE'}
                        </span>
                      </td>
                      {user?.role === 'ADMINISTRADOR' && (
                        <td className="p-4 text-center">
                          <button 
                            onClick={() => { setCurrentOrder(order); setIsEditing(true); }} 
                            className="px-2.5 py-1 text-[11px] font-bold text-slate-700 bg-white border border-slate-200 rounded-lg hover:bg-slate-50 hover:border-slate-300 transition-all shadow-sm"
                          >
                            Modificar
                          </button>
                        </td>
                      )}
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
}