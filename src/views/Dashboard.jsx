import React from 'react';

export default function Dashboard({ orders }) {
  const activeCount = orders?.filter(o => o.status === 'En Proceso').length || 1;

  return (
    <div className="space-y-6 animate-fadeIn">
      <div>
        <h1 className="text-xl md:text-2xl font-bold text-slate-900">Dashboard de Ingeniería</h1>
        <p className="text-xs md:text-sm text-slate-500">Métricas analíticas globales de la planta industrial</p>
      </div>
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm">
          <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block">Órdenes Activas en Taller</span>
          <div className="flex items-baseline gap-2 mt-1">
            <span className="text-3xl font-black text-slate-900">{activeCount}</span>
            <span className="text-xs font-bold text-orange-500">Trabajos Corriendo</span>
          </div>
        </div>
        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm">
          <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block">Eficiencia Operativa Promedio</span>
          <div className="flex items-baseline gap-2 mt-1">
            <span className="text-3xl font-black text-emerald-600">98.4%</span>
            <span className="text-xs font-bold text-slate-400">On-Time Delivery</span>
          </div>
        </div>
        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm">
          <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block">Merma Crítica de Material</span>
          <div className="flex items-baseline gap-2 mt-1">
            <span className="text-3xl font-black text-rose-500">1.2%</span>
            <span className="text-xs font-bold text-slate-400">Descarte de papel</span>
          </div>
        </div>
      </div>
    </div>
  );
}