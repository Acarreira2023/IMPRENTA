import React, { useEffect, useState } from 'react';
import { getKpis } from '../services/firestore.js';
import { useAuth } from '../context/AuthContext.jsx';

export default function Dashboard() {
  const { user } = useAuth();
  const [kpis, setKpis] = useState({
    pedidosTotales: 0,
    pedidosPendientes: 0,
    pedidosEnProceso: 0,
    pedidosCompletados: 0,
    pedidosEntregados: 0,
    mermaTotal: 0
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const cargarMetricasPlanta = async () => {
      try {
        setLoading(true);
        const dataKpis = await getKpis();
        setKpis(dataKpis);
      } catch (error) {
        console.error("Error al obtener los KPIs de producción:", error);
      } finally {
        setLoading(false);
      }
    };

    cargarMetricasPlanta();
  }, [user]); // Se recalcula automáticamente si el navbar cambia entre Demo y Real

  if (loading) {
    return (
      <div className="p-6 text-slate-500 font-medium animate-pulse text-xs md:text-sm">
        Calculando métricas analíticas globales de la planta...
      </div>
    );
  }

  return (
    <div className="space-y-6 animate-fadeIn">
      {/* Encabezado Principal */}
      <div>
        <h1 className="text-xl md:text-2xl font-bold text-slate-900">Dashboard de Ingeniería</h1>
        <p className="text-xs md:text-sm text-slate-500">Métricas analíticas globales de la planta industrial</p>
      </div>

      {/* Grilla de Tarjetas KPI */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        
        {/* KPI 1: Órdenes Activas */}
        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm transition-all hover:border-slate-300">
          <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block">Órdenes Activas en Taller</span>
          <div className="flex items-baseline gap-2 mt-1">
            <span className="text-3xl font-black text-slate-900">
              {kpis.pedidosEnProceso}
            </span>
            <span className="text-xs font-bold text-amber-500">Trabajos Corriendo</span>
          </div>
          <p className="text-[10px] text-slate-400 mt-2">
            {kpis.pedidosPendientes} órdenes en cola de espera (preprensa)
          </p>
        </div>

        {/* KPI 2: Eficiencia de Entrega */}
        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm transition-all hover:border-slate-300">
          <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block">Eficiencia Operativa Promedio</span>
          <div className="flex items-baseline gap-2 mt-1">
            <span className="text-3xl font-black text-emerald-600">
              {kpis.pedidosTotales > 0 
                ? ((kpis.pedidosCompletados + kpis.pedidosEntregados) / kpis.pedidosTotales * 100).toFixed(1) 
                : '100'}%
            </span>
            <span className="text-xs font-bold text-slate-400">On-Time Delivery</span>
          </div>
          <p className="text-[10px] text-slate-400 mt-2">
            Basado en {kpis.pedidosTotales} órdenes totales registradas
          </p>
        </div>

        {/* KPI 3: Merma Crítica de Material */}
        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm transition-all hover:border-slate-300">
          <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block">Merma de Material Acumulada</span>
          <div className="flex items-baseline gap-2 mt-1">
            <span className={`text-3xl font-black ${kpis.mermaTotal > 1000 ? 'text-rose-500' : 'text-slate-800'}`}>
              {kpis.mermaTotal.toLocaleString()}
            </span>
            <span className="text-xs font-bold text-slate-400">Unidades / Pliegos</span>
          </div>
          <p className="text-[10px] text-slate-400 mt-2">
            Descarte estimado en procesos de tirada y puesta a punto
          </p>
        </div>

      </div>
    </div>
  );
}