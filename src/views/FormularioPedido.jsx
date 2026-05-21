import React, { useState, useEffect } from 'react';

export default function FormularioPedido({ order, onSave, onCancel }) {
  const [formData, setFormData] = useState({
    id: order?.id || `PED-2026-${Math.floor(Math.random() * 900 + 100)}`,
    client: order?.client || '',
    description: order?.description || '',
    quantity: order?.quantity || 1000,
    status: order?.status || 'Pendiente',
    stages: order?.stages || { ingreso: { date: new Date().toLocaleDateString() } },
    currentStageListSnapshot: order?.currentStageListSnapshot || null
  });

  useEffect(() => {
    if (order) setFormData(order);
  }, [order]);

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!formData.client.trim() || !formData.description.trim()) return;
    onSave(formData);
  };

  return (
    <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm max-w-xl mx-auto space-y-6 animate-fadeIn">
      <h2 className="text-base font-bold text-slate-900 border-b border-slate-100 pb-2">
        {order ? `Modificar Orden: ${order.id}` : 'Alta de Nuevo Pedido Gráfico Industrial'}
      </h2>
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label className="block text-[10px] font-bold text-slate-500 uppercase tracking-wider mb-1">Cliente Solicitante *</label>
          <input type="text" value={formData.client} onChange={e => setFormData({...formData, client: e.target.value})} className="w-full px-3 py-2 border border-slate-200 rounded-xl text-xs outline-none focus:ring-2 focus:ring-orange-500/20 focus:border-orange-500" required />
        </div>
        <div>
          <label className="block text-[10px] font-bold text-slate-500 uppercase tracking-wider mb-1">Ficha Técnica / Descripción *</label>
          <input type="text" value={formData.description} onChange={e => setFormData({...formData, description: e.target.value})} className="w-full px-3 py-2 border border-slate-200 rounded-xl text-xs outline-none focus:ring-2 focus:ring-orange-500/20 focus:border-orange-500" required />
        </div>
        <div>
          <label className="block text-[10px] font-bold text-slate-500 uppercase tracking-wider mb-1">Tirada Requerida</label>
          <input type="number" value={formData.quantity} onChange={e => setFormData({...formData, quantity: Math.max(1, Number(e.target.value))})} className="w-full px-3 py-2 border border-slate-200 rounded-xl text-xs font-mono outline-none focus:ring-2 focus:ring-orange-500/20 focus:border-orange-500" required />
        </div>
        <div className="flex justify-end gap-2 pt-4 border-t border-slate-100">
          <button type="button" onClick={onCancel} className="px-4 py-2 border border-slate-200 rounded-xl text-xs font-bold text-slate-600 hover:bg-slate-50">Cancelar</button>
          <button type="submit" className="px-4 py-2 bg-orange-500 text-white text-xs font-bold rounded-xl hover:bg-orange-600 shadow-sm">Guardar Ficha</button>
        </div>
      </form>
    </div>
  );
}