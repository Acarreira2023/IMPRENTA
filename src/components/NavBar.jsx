import React from 'react';
import { useAuth } from '../context/AuthContext.jsx';

export default function Navbar() {
  const { user, changeRoleDevMode, logout } = useAuth();

  // Normalizamos el rol actual para evitar inconsistencias de formato (Upper/Lower)
  const userRoleNormalized = user?.role?.toUpperCase() || user?.rol?.toUpperCase() || 'CLIENTE';

  return (
    <header className="h-16 bg-white border-b border-slate-200 flex items-center justify-between px-6 z-10 shadow-sm">
      <div className="flex items-center gap-4">
        <span className="text-xs font-bold text-slate-400 tracking-widest uppercase hidden lg:inline">
          Consola Dinámica
        </span>
        
        {/* Switcheador Rápido de Taller (Sandbox / Cloud Nube) */}
        <div className="flex bg-slate-100 p-1 rounded-xl gap-2 border border-slate-200 text-[10px] font-bold">
          {/* Módulo de Inyección Demo */}
          <div className="flex items-center gap-1 bg-white px-2 py-0.5 rounded-lg shadow-sm border border-slate-200/50">
            <span className="text-amber-500">⚙️</span> DEMO:
            {['ADMINISTRADOR', 'OPERARIO', 'CLIENTE'].map(r => (
              <button 
                key={`demo-${r}`} 
                onClick={() => changeRoleDevMode(r, true)}
                className={`px-2 py-0.5 rounded-md transition-all ${
                  user?.isDemo && userRoleNormalized === r 
                    ? 'bg-amber-500 text-white shadow-sm' 
                    : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                {r.slice(0,4)}.
              </button>
            ))}
          </div>

          {/* Módulo de Inyección Real (Simulación de Conexión Cloud) */}
          <div className="flex items-center gap-1 bg-white px-2 py-0.5 rounded-lg shadow-sm border border-slate-200/50">
            <span className="text-emerald-500">☁️</span> REAL:
            {['ADMINISTRADOR', 'OPERARIO', 'CLIENTE'].map(r => (
              <button 
                key={`real-${r}`} 
                onClick={() => changeRoleDevMode(r, false)}
                className={`px-2 py-0.5 rounded-md transition-all ${
                  !user?.isDemo && userRoleNormalized === r 
                    ? 'bg-emerald-500 text-white shadow-sm' 
                    : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                {r.slice(0,4)}.
              </button>
            ))}
          </div>
        </div>
      </div>
      
      {/* Sección Perfil de Operador y Desconexión */}
      <div className="flex items-center gap-3 border-l border-slate-100 pl-4">
        <div className="text-right hidden sm:block">
          <p className="text-xs font-bold text-slate-800">
            {user?.name || user?.nombre || 'Operador Anónimo'}
          </p>
          <p className={`text-[9px] font-mono font-bold uppercase tracking-wider ${user?.isDemo ? 'text-amber-600' : 'text-emerald-600'}`}>
            {userRoleNormalized} ({user?.isDemo ? 'Sandbox Local' : 'Cloud Real'})
          </p>
        </div>
        
        {/* Botón de Salida con limpieza de LocalStorage vía Contexto */}
        <button 
          onClick={logout}
          className="ml-2 px-2.5 py-1 text-[10px] font-bold text-slate-500 bg-slate-50 hover:bg-rose-50 hover:text-rose-600 border border-slate-200 rounded-lg transition-all shadow-sm flex items-center gap-1"
        >
          🚪 Salir
        </button>
      </div>
    </header>
  );
}