import React from 'react';
import { Users } from 'lucide-react';

const Usuarios = () => {
  return (
    <div className="p-8">
      <div className="flex items-center gap-3 mb-6">
        <Users className="w-8 h-8 text-blue-600" />
        <h1 className="text-2xl font-black text-gray-900">Gestión de Usuarios</h1>
      </div>
      <div className="bg-white p-12 rounded-3xl border border-dashed border-gray-200 text-center text-gray-400">
        <p>Aquí podrás administrar los permisos del personal.</p>
      </div>
    </div>
  );
};

export default Usuarios;