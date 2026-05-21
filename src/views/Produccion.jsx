import React, { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext.jsx';
import { getPedidos, actualizarPedido } from '../services/firestore.js';

function DynamicStatusFlow({ orderStages, currentStageList, etapaActual }) {
  return (
    <div className="w-full py-6 overflow-x-auto bg-slate-900 text-white rounded-2xl p-4 shadow-inner border border-slate-800">
      <div className="flex items-center min-w-[800px] justify-between px-2">
        {currentStageList.map((stageItem, idx) => {
          const orderStageData = orderStages?.[stageItem.id] || {};
          
          // Lógica de estados visuales basada en la etapa de la base de datos
          let statusClass = "bg-slate-800 text-slate-500 border-slate-700"; 
          
          if (stageItem.id === etapaActual) {
            statusClass = "bg-orange-500 text-white ring-4 ring-orange-950/50 border-orange-400 animate-pulse";
          } else if (orderStageData.completed || orderStageData.date || idx < currentStageList.findIndex(s => s.id === etapaActual)) {
            statusClass = "bg-emerald-500 text-white ring-4 ring-emerald-950/50 border-emerald-400";
          }

          const isCompleted = orderStageData.completed || idx < currentStageList.findIndex(s => s.id === etapaActual);

          return (
            <React.Fragment key={stageItem.id}>
              <div className="relative flex flex-col items-center flex-1 group">
                <div className={`w-9 h-9 rounded-full flex items-center justify-center font-bold text-xs border ${statusClass}`}>
                  {isCompleted ? '✓' : idx + 1}
                </div>
                <span className="text-[11px] font-bold mt-2 text-center text-slate-300 truncate w-full px-1">
                  {stageItem.label}
                </span>
                {stageItem.isCompound && (
                  <div className="flex gap-1 mt-1.5">
                    <span className={`w-3 h-1.5 rounded-sm ${isCompleted || etapaActual === 'impresion' ? 'bg-orange-400' : 'bg-slate-700'}`} />
                    <span className={`w-3 h-1.5 rounded-sm ${isCompleted && stageItem.id !== etapaActual ? 'bg-emerald-400' : 'bg-slate-700'}`} />
                  </div>
                )}
              </div>
              {idx < currentStageList.length - 1 && (
                <div className={`h-1 flex-1 mx-1 rounded ${isCompleted ? 'bg-emerald-500' : 'bg-slate-800'}`} />
              )}
            </React.Fragment>
          );
        })}
      </div>
    </div>
  );
}

export default function Produccion() {
  const { user } = useAuth();
  const [orders, setOrders] = useState([]);
  const [selectedOrder, setSelectedOrder] = useState(null);
  const [loading, setLoading] = useState(true);

  const masterStages = [
    { id: 'preprensa', label: 'Pre-Prensa / CtP', isCompound: false },
    { id: 'preparado', label: 'Puesta a Punto', isCompound: false },
    { id: 'impresion', label: 'Tirada de Impresión', isCompound: true },       
    { id: 'encuadernacion', label: 'Terminación / Entrega', isCompound: false }
  ];

  const cargarColaProduccion = async () => {
    try {
      setLoading(true);
      // Filtra órdenes activas (en proceso o pendientes) que requieran monitoreo de planta
      const todosLosPedidos = await getPedidos(user?.role, user?.uid);
      const activos = todosLosPedidos.filter(p => p.estado === 'en_proceso' || p.estado === 'pendiente');
      setOrders(activos);
      
      // Sincronizar el pedido seleccionado si está abierto
      if (selectedOrder) {
        const actualizado = activos.find(o => o.id === selectedOrder.id);
        if (actualizado) setSelectedOrder(actualizado);
      }
    } catch (error) {
      console.error("Error en taller de producción:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    cargarColaProduccion();
  }, [user]);

  const avanzarEtapa = async (order) => {
    const currentIndex = masterStages.findIndex(s => s.id === order.etapaActual);
    if (currentIndex < masterStages.length - 1) {
      const siguienteEtapa = masterStages[currentIndex + 1].id;
      const cambio = { 
        etapaActual: siguienteEtapa,
        estado: 'en_proceso'
      };
      await actualizarPedido(order.id, cambio);
      await cargarColaProduccion();
    } else {
      // Si llegó al final, se marca la orden como Completada
      await actualizarPedido(order.id, { estado: 'completado', etapaActual: 'encuadernacion' });
      setSelectedOrder(null);
      await cargarColaProduccion();
    }
  };

  if (loading && orders.length === 0) {
    return <p className="text-xs font-mono p-6 text-slate-400 animate-pulse">Sincronizando flujos de planta...</p>;
  }

  return (
    <div className="space-y-6 animate-fadeIn">
      <div>
        <h1 className="text-xl md:text-2xl font-bold text-slate-900">Planta de Fabricación</h1>
        <p className="text-xs md:text-sm text-slate-500">Monitoreo de flujo físico y control de maquinaria en tiempo real</p>
      </div>

      {selectedOrder ? (
        <div className="bg-white rounded-2xl border border-slate-200 p-6 space-y-6 shadow-sm">
          <div className="flex justify-between items-center border-b border-slate-100 pb-3">
            <button onClick={() => setSelectedOrder(null)} className="text-xs font-bold text-orange-500 hover:text-orange-600 transition-colors">
              ← Volver al Panel de Planta
            </button>
            <span className="font-mono text-xs font-bold bg-slate-100 px-2.5 py-1 text-slate-700 rounded-lg">
              {selectedOrder.id}
            </span>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 bg-slate-50 p-4 rounded-xl text-xs">
            <div>
              <p className="text-[10px] uppercase font-bold text-slate-400">Cliente Solicitante</p>
              <p className="font-bold text-slate-800 mt-0.5">{selectedOrder.clienteNombre || 'Sin asignar'}</p>
            </div>
            <div>
              <p className="text-[10px] uppercase font-bold text-slate-400">Especificación del Trabajo</p>
              <p className="text-slate-700 mt-0.5">{selectedOrder.descripcion}</p>
            </div>
          </div>

          <DynamicStatusFlow 
            orderStages={selectedOrder.stages} 
            currentStageList={masterStages} 
            etapaActual={selectedOrder.etapaActual || 'preprensa'} 
          />

          {/* Acciones del Operario / Administrador */}
          {(user?.role === 'ADMINISTRADOR' || user?.role === 'OPERARIO') && (
            <div className="flex justify-end pt-2">
              <button 
                onClick={() => avanzarEtapa(selectedOrder)}
                className="px-4 py-2 bg-orange-500 hover:bg-orange-600 text-white font-bold text-xs rounded-xl shadow-sm transition-colors"
              >
                {selectedOrder.etapaActual === 'encuadernacion' ? 'Finalizar y Archivar Orden' : 'Avanzar Siguiente Etapa →'}
              </button>
            </div>
          )}
        </div>
      ) : (
        <div className="grid grid-cols-1 gap-3">
          {orders.length === 0 ? (
            <div className="bg-white p-8 text-center border border-slate-200 rounded-2xl text-slate-400 italic text-xs">
              No hay trabajos corriendo en las máquinas en este momento.
            </div>
          ) : (
            orders.map(order => (
              <div key={order.id} className="bg-white p-4 rounded-xl border border-slate-200 flex justify-between items-center shadow-sm transition-all hover:border-slate-300">
                <div>
                  <div className="flex items-center gap-2">
                    <span className="font-mono font-bold text-orange-500 text-xs">{order.id}</span>
                    <span className="text-[10px] font-bold bg-slate-100 text-slate-600 px-1.5 py-0.5 rounded uppercase">
                      {order.etapaActual || 'preprensa'}
                    </span>
                  </div>
                  <span className="text-sm font-bold text-slate-800 block mt-1">{order.descripcion}</span>
                  <span className="text-[11px] text-slate-400">{order.clienteNombre}</span>
                </div>
                <button 
                  onClick={() => setSelectedOrder(order)} 
                  className="px-4 py-2 bg-slate-900 hover:bg-slate-800 text-white font-bold text-xs rounded-xl transition-all shadow-sm"
                >
                  Monitorear
                </button>
              </div>
            ))
          )}
        </div>
      )}
    </div>
  );
}