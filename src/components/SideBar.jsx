import React from 'react';
import { useAuth } from '../context/AuthContext.jsx';

export default function Sidebar({ currentView, setCurrentView }) {
  const { user, changeRoleDevMode } = useAuth();

  const menuItems = [
    { id: 'dashboard', label: 'Dashboard', icon: '📊', allowedRoles: ['ADMINISTRADOR', 'OPERARIO', 'CLIENTE'] },
    { id: 'pedidos', label: 'Pedidos', icon: '📦', allowedRoles: ['ADMINISTRADOR', 'CLIENTE'] },
    { id: 'produccion', label: 'Planta de Producción', icon: '🏭', allowedRoles: ['ADMINISTRADOR', 'OPERARIO'] },
    { id: 'reportes', label: 'Auditoría e Informes', icon: '📝', allowedRoles: ['ADMINISTRADOR'] }
  ];

  // Normalizamos el rol a mayúsculas para evitar colisiones de tipado ('cliente' vs 'CLIENTE')
  const userRoleNormalized = user?.role?.toUpperCase() || user?.rol?.toUpperCase() || 'CLIENTE';

  const visibleItems = menuItems.filter(item => 
    item.allowedRoles.includes(userRoleNormalized)
  );

  return (
    <aside className="w-18 md:w-64 bg-slate-900 h-full flex flex-col transition-all duration-300 border-r border-slate-950">
      {/* Isotipo y Logotipo Corporativo */}
      <div className="h-16 flex items-center px-4 md:px-6 bg-slate-950 border-b border-slate-850 gap-2">
        <div className="w-7 h-7 bg-orange-500 rounded-lg flex items-center justify-center text-white font-black text-sm shadow-md animate-pulse">
          P
        </div>
        <span className="text-sm font-black text-white tracking-wider hidden md:block">
          IMPRENTA <span className="text-orange-500 text-xs font-bold">CORE</span>
        </span>
      </div>

      {/* Navegación Principal Dinámica */}
      <nav className="flex-1 p-3 space-y-1">
        {visibleItems.map(item => {
          const isActive = currentView === item.id;
          return (
            <button
              key={item.id}
              onClick={() => setCurrentView(item.id)}
              className={`w-full flex items-center gap-3 p-3 rounded-xl text-xs font-bold transition-all duration-150 ${
                isActive 
                  ? 'bg-orange-500 text-white shadow-md' 
                  : 'text-slate-400 hover:bg-slate-800/50 hover:text-white'
              }`}
            >
              <span className="text-sm">{item.icon}</span>
              <span className="truncate hidden md:block">{item.label}</span>
            </button>
          );
        })}
      </nav>

      {/* Consola de Desarrollo Rápida (Solo visible si es modo DEMO) */}
      {user?.isDemo && (
        <div className="p-3 mx-2 my-2 bg-slate-950 rounded-xl border border-slate-800 space-y-1.5 hidden md:block">
          <span className="text-[9px] font-bold text-amber-500 tracking-wider uppercase block">
            Simulador de Roles (Dev)
          </span>
          <div className="grid grid-cols-3 gap-1 text-[9px] font-bold">
            <button 
              onClick={() => changeRoleDevMode('ADMINISTRADOR')} 
              className={`p-1 rounded transition-colors ${userRoleNormalized === 'ADMINISTRADOR' ? 'bg-amber-500 text-slate-950' : 'bg-slate-900 text-slate-400 hover:text-white'}`}
            >
              Admin
            </button>
            <button 
              onClick={() => changeRoleDevMode('OPERARIO')} 
              className={`p-1 rounded transition-colors ${userRoleNormalized === 'OPERARIO' ? 'bg-amber-500 text-slate-950' : 'bg-slate-900 text-slate-400 hover:text-white'}`}
            >
              Operario
            </button>
            <button 
              onClick={() => changeRoleDevMode('CLIENTE')} 
              className={`p-1 rounded transition-colors ${userRoleNormalized === 'CLIENTE' ? 'bg-amber-500 text-slate-950' : 'bg-slate-900 text-slate-400 hover:text-white'}`}
            >
              Cliente
            </button>
          </div>
        </div>
      )}

      {/* Footer de Seguridad */}
      <div className="p-4 border-t border-slate-850 text-center hidden md:block">
        <span className="text-[9px] text-slate-500 font-mono font-bold tracking-widest block">
          PROPIEDAD INDUSTRIAL CONFIDENCIAL
        </span>
      </div>
    </aside>
  );
}