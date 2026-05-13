import React from 'react';
import { KeyRound, Save } from 'lucide-react';

const CambiarPassword = () => {
  return (
    <div className="max-w-md mx-auto mt-10 p-8 bg-white rounded-3xl shadow-sm border border-gray-100">
      <div className="flex flex-col items-center mb-8">
        <div className="p-4 bg-orange-100 rounded-2xl mb-4">
          <KeyRound className="w-8 h-8 text-orange-600" />
        </div>
        <h1 className="text-xl font-bold text-gray-900">Actualizar Contraseña</h1>
      </div>

      <form className="space-y-4">
        <div>
          <label className="text-xs font-black text-gray-400 uppercase ml-2">Contraseña Actual</label>
          <input type="password" placeholder="••••••••" className="w-full p-4 bg-gray-50 rounded-2xl border-none outline-none focus:ring-2 focus:ring-orange-500" />
        </div>
        <div>
          <label className="text-xs font-black text-gray-400 uppercase ml-2">Nueva Contraseña</label>
          <input type="password" placeholder="Nueva contraseña" className="w-full p-4 bg-gray-50 rounded-2xl border-none outline-none focus:ring-2 focus:ring-orange-500" />
        </div>
        <button className="w-full bg-gray-900 text-white p-4 rounded-2xl font-bold flex items-center justify-center gap-2 hover:bg-black transition-all">
          <Save className="w-5 h-5" /> Guardar Cambios
        </button>
      </form>
    </div>
  );
};

export default CambiarPassword;