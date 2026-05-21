import React, { useState } from 'react';
import { useAuth } from '../context/AuthContext';

function DynamicStatusFlow({ orderStages, currentStageList }) {
  return (
    <div className="w-full py-6 overflow-x-auto bg-slate-900 text-white rounded-2xl p-4 shadow-inner border border-slate-800">
      <div className="flex items-center min-w-[800px] justify-between px-2">
        {currentStageList.map((stageItem, idx) => {
          const orderStageData = orderStages?.[stageItem.id] || {};
          let statusClass = "bg-slate-800 text-slate-500 border-slate-700"; 
          if (orderStageData.completed || orderStageData.date) statusClass = "bg-emerald-500 text-white ring-4 ring-emerald-950/50 border-emerald-400";
          else if (orderStageData.start || orderStageData.active) statusClass = "bg-orange-500 text-white ring-4 ring-orange-950/50 border-orange-400 animate-pulse";

          return (
            <React.Fragment key={stageItem.id}>
              <div className="relative flex flex-col items-center flex-1 group">
                <div className={`w-9 h-9 rounded-full flex items-center justify-center font-bold text-xs border ${statusClass}`}>{orderStageData.completed ? '✓' : idx + 1}</div>
                <span className="text-[11px] font-bold mt-2 text-center text-slate-300 truncate w-full px-1">{stageItem.label}</span>
                {stageItem.isCompound && (
                  <div className="flex gap-1 mt-1.5">
                    <span className={`w-3 h-1.5 rounded-sm ${orderStageData.tapa?.end ? 'bg-emerald-400' : 'bg-slate-700'}`} />
                    <span className={`w-3 h-1.5 rounded-sm ${orderStageData.interior?.end ? 'bg-emerald-400' : 'bg-slate-700'}`} />
                  </div>
                )}
              </div>
              {idx < currentStageList.length - 1 && <div className={`h-1 flex-1 mx-1 rounded ${orderStageData.completed ? 'bg-emerald-500' : 'bg-slate-800'}`} />}
            </React.Fragment>
          );
        })}
      </div>
    </div>
  );
}

export default function Produccion() {
  const { user } = useAuth();
  const [selectedOrder, setSelectedOrder] = useState(null);
  const [masterStages] = useState([
    { id: 'ingreso', label: 'Ingreso', isCompound: false },
    { id: 'preparado', label: 'Preparado', isCompound: false },
    { id: 'impresion', label: 'Impresión', isCompound: true },       
    { id: 'entregado', label: 'Entregado', isCompound: false }
  ]);

  const mockOrders = [
    { id: 'PED-MAIN-01', client: 'Empresa Alfa', description: 'Revistas A4', quantity: 500, stages: { ingreso: { date: '20/05/2026', completed: true } } }
  ];

  return (
    <div className="space-y-6 animate-fadeIn">
      <h1 className="text-xl font-bold text-slate-900">Planta de Fabricación</h1>
      {selectedOrder ? (
        <div className="bg-white rounded-2xl border p-6 space-y-4">
          <button onClick={() => setSelectedOrder(null)} className="text-xs font-bold text-orange-500">← Volver</button>
          <DynamicStatusFlow orderStages={selectedOrder.stages} currentStageList={masterStages} />
        </div>
      ) : (
        <div className="grid grid-cols-1 gap-2">
          {mockOrders.map(order => (
            <div key={order.id} className="bg-white p-4 rounded-xl border border-slate-200 flex justify-between items-center shadow-sm">
              <div>
                <span className="font-mono font-bold text-orange-500 text-xs block">{order.id}</span>
                <span className="text-sm font-bold text-slate-800">{order.description}</span>
              </div>
              <button onClick={() => setSelectedOrder(order)} className="px-4 py-2 bg-slate-900 text-white font-bold text-xs rounded-xl">Monitorear</button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}