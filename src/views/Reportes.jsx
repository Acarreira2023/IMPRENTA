import React, { useEffect, useState } from 'react';
import { getKpis } from '../services/firestore.js';
import { useAuth } from '../context/AuthContext.jsx';

export default function Reportes() {
  const { user } = useAuth();
  const [kpis, setKpis] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const calcularBalancesPlanta = async () => {
      try {
        setLoading(true);
        const dataKpis = await getKpis();
        setKpis(dataKpis);
      } catch (error) {
        console.error("Error al compilar informe de auditoría:", error);
      } finally {
        setLoading(false);
      }
    };

    calcularBalancesPlanta();
  }, [user]);

  if (loading) {
    return (
      <p className="text-xs font-mono p-6 text-slate-400 animate-pulse">
        Compilando balance consolidado de materiales...
      </p>
    );
  }

  // Cálculos matemáticos de balance industrial
  const unidadesProcesadas = kpis?.pedidosTotales || 0;
  const mermaTotal = kpis?.mermaTotal || 0;
  
  // Asumimos un estimado de volumen de tirada total para el ratio (o 100% como fallback seguro)
  const ratioDescarte = unidadesProcesadas > 0 ? (mermaTotal / (unidadesProcesadas * 2000) * 100) : 0;
  const eficienciaMaterial = Math.max(0, 100 - ratioDescarte);

  return (
    <div className="space-y-6 animate-fadeIn">
      {/* Encabezado Técnico */}
      <div>
        <h1 className="text-xl md:text-2xl font-bold text-slate-900">Auditoría e Informes</h1>
        <p className="text-xs md:text-sm text-slate-500">Balances físicos e históricos de rendimiento de insumos</p>
      </div>

      {/* Tarjeta de Control Analítico */}
      <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-6">
        <div className="border-b border-slate-100 pb-3">
          <h2 className="text-xs font-bold text-slate-400 uppercase tracking-wider">
            Balance Consolidado de Materiales (Papel / Pliegos)
          </h2>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
          <div className="space-y-1">
            <span className="text-[11px] font-medium text-slate-400">Órdenes Auditadas en Historial</span>
            <p className="text-2xl font-black text-slate-800">{unidadesProcesadas} trabajos</p>
          </div>
          
          <div className="space-y-1">
            <span className="text-[11px] font-medium text-slate-400">Volumen Descartado por Puesta a Punto</span>
            <p className="text-2xl font-black text-rose-500">{mermaTotal.toLocaleString()} un.</p>
          </div>
        </div>

        {/* Indicador de Barra de Eficiencia Gráfica */}
        <div className="space-y-2 pt-2">
          <div className="flex justify-between items-center text-[11px] font-bold">
            <span className="text-slate-500">Eficiencia de Aprovechamiento Neto</span>
            <span className="text-emerald-600 font-mono">{eficienciaMaterial.toFixed(1)}%</span>
          </div>
          <div className="w-full h-2.5 bg-slate-100 rounded-full overflow-hidden flex">
            <div 
              className="h-full bg-emerald-500 transition-all duration-500" 
              style={{ width: `${eficienciaMaterial}%` }} 
            />
            <div 
              className="h-full bg-rose-500 transition-all duration-500" 
              style={{ width: `${100 - eficienciaMaterial}%` }} 
            />
          </div>
        </div>
      </div>

      {/* Nota corporativa al pie */}
      <div className="bg-slate-50 p-4 rounded-xl border border-slate-100 text-[11px] text-slate-500 italic">
        💡 Los datos expresados en este informe contemplan las diferencias entre la cantidad original solicitada y la cantidad ajustada final declarada por el sector de encuadernación.
      </div>
    </div>
  );
}