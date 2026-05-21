import React, { useState, useEffect } from 'react';
import { getClientes } from '../services/firestore.js';

export default function FormularioPedido({ order, onSave, onCancel }) {
  const [clientes, setClientes] = useState([]);
  const [loadingClientes, setLoadingClientes] = useState(false);
  
  const [formData, setFormData] = useState({
    id: order?.id || `PED-${Math.floor(Math.random() * 900 + 100)}`,
    clienteId: order?.clienteId || '',
    clienteNombre: order?.clienteNombre || '',
    descripcion: order?.descripcion || '',
    cantidadOriginal: order?.cantidadOriginal || 1000,
    cantidadAjustada: order?.cantidadAjustada || order?.cantidadOriginal || 1000,
    estado: order?.estado || 'pendiente',
    etapaActual: order?.etapaActual || 'preprensa',
    maquinaAsignada: order?.maquinaAsignada || 'Sin asignar'
  });

  // Cargar lista de clientes al montar para poblar el select corporativo
  useEffect(() => {
    const cargarClientesImprenta = async () => {
      try {
        setLoadingClientes(true);
        const data = await getClientes();
        setClientes(data);
        
        // Si no hay cliente seleccionado por defecto, toma el primero de la lista
        if (!order && data.length > 0 && !formData.clienteId) {
          setFormData(prev => ({
            ...prev,
            clienteId: data[0].id,
            clienteNombre: data[0].nombre
          }));
        }
      } catch (error) {
        console.error("Error al cargar clientes en el formulario:", error);
      } finally {
        setLoadingClientes(false);
      }
    };
    cargarClientesImprenta();
  }, [order]);

  // Sincronizar si la prop 'order' cambia desde el componente padre
  useEffect(() => {
    if (order) {
      setFormData({
        id: order.id,
        clienteId: order.clienteId || '',
        clienteNombre: order.clienteNombre || '',
        descripcion: order.descripcion || '',
        cantidadOriginal: order.cantidadOriginal || 1000,
        cantidadAjustada: order.cantidadAjustada || order.cantidadOriginal || 1000,
        estado: order.estado || 'pendiente',
        etapaActual: order.etapaActual || 'preprensa',
        maquinaAsignada: order.maquinaAsignada || 'Sin asignar'
      });
    }
  }, [order]);

  const handleClienteChange = (e) => {
    const selectedId = e.target.value;
    const clienteEncontrado = clientes.find(c => c.id === selectedId);
    setFormData({
      ...formData,
      clienteId: selectedId,
      clienteNombre: clienteEncontrado ? clienteEncontrado.nombre : ''
    });
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!formData.clienteId || !formData.descripcion.trim()) return;
    onSave(formData);
  };

  return (
    <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm max-w-xl mx-auto space-y-6 animate-fadeIn">
      <h2 className="text-base font-bold text-slate-900 border-b border-slate-100 pb-2">
        {order ? `Modificar Orden: ${order.id}` : 'Alta de Nuevo Pedido Gráfico Industrial'}
      </h2>
      
      <form onSubmit={handleSubmit} className="space-y-4">
        {/* Selector de Cliente */}
        <div>
          <label className="block text-[10px] font-bold text-slate-500 uppercase tracking-wider mb-1">
            Cliente Solicitante *
          </label>
          {loadingClientes ? (
            <div className="text-xs text-slate-400 p-2 animate-pulse">Sincronizando cuentas...</div>
          ) : (
            <select 
              value={formData.clienteId} 
              onChange={handleClienteChange}
              className="w-full px-3 py-2 border border-slate-200 rounded-xl text-xs bg-white outline-none focus:ring-2 focus:ring-orange-500/20 focus:border-orange-500"
              required
            >
              <option value="" disabled>Seleccione un cliente de la nómina...</option>
              {clientes.map(c => (
                <option key={c.id} value={c.id}>{c.nombre}</option>
              ))}
            </select>
          )}
        </div>

        {/* Descripción técnica */}
        <div>
          <label className="block text-[10px] font-bold text-slate-500 uppercase tracking-wider mb-1">
            Ficha Técnica / Descripción *
          </label>
          <input 
            type="text" 
            value={formData.descripcion} 
            onChange={e => setFormData({...formData, descripcion: e.target.value})} 
            placeholder="Ej: Libros Revistas A4 - Papel Ilustración 150g"
            className="w-full px-3 py-2 border border-slate-200 rounded-xl text-xs outline-none focus:ring-2 focus:ring-orange-500/20 focus:border-orange-500" 
            required 
          />
        </div>

        {/* Tirada Requerida */}
        <div>
          <label className="block text-[10px] font-bold text-slate-500 uppercase tracking-wider mb-1">
            Tirada Requerida (Ejemplares / Pliegos)
          </label>
          <input 
            type="number" 
            value={formData.cantidadOriginal} 
            onChange={e => {
              const valor = Math.max(1, Number(e.target.value));
              setFormData({
                ...formData, 
                cantidadOriginal: valor,
                // Mantenemos la ajustada igual a la original inicialmente por defecto
                cantidadAjustada: order ? formData.cantidadAjustada : valor 
              });
            }} 
            className="w-full px-3 py-2 border border-slate-200 rounded-xl text-xs font-mono outline-none focus:ring-2 focus:ring-orange-500/20 focus:border-orange-500" 
            required 
          />
        </div>

        {/* Botones de acción */}
        <div className="flex justify-end gap-2 pt-4 border-t border-slate-100">
          <button 
            type="button" 
            onClick={onCancel} 
            className="px-4 py-2 border border-slate-200 rounded-xl text-xs font-bold text-slate-600 hover:bg-slate-50 transition-colors"
          >
            Cancelar
          </button>
          <button 
            type="submit" 
            className="px-4 py-2 bg-orange-500 text-white text-xs font-bold rounded-xl hover:bg-orange-600 shadow-sm transition-colors"
          >
            Guardar Ficha
          </button>
        </div>
      </form>
    </div>
  );
}