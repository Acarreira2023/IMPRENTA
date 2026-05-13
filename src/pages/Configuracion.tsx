import React, { useEffect, useState } from 'react';
import {
  getUsuarios,
  crearUsuario,
} from '../services/firestore';
import { Usuario, UserRole } from '../types';
import { cn } from '../utils/cn';
import {
  Users,
  UserPlus,
  Settings,
  Monitor,
  ShieldCheck,
  Briefcase,
  Save,
  X
} from 'lucide-react';

type Tab = 'usuarios' | 'clientes' | 'maquinas';

export const Configuracion: React.FC = () => {
  const [activeTab, setActiveTab] = useState<Tab>('usuarios');
  const [usuarios, setUsuarios] = useState<Usuario[]>([]);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [loading, setLoading] = useState(true);

  // Estado para el formulario de nuevo usuario
  const [nuevoUser, setNuevoUser] = useState({
    nombre: '',
    email: '',
    rol: 'operario' as UserRole,
  });

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    setLoading(true);
    const users = await getUsuarios();
    setUsuarios(users);
    setLoading(false);
  };

  const handleCrearUsuario = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await crearUsuario(nuevoUser);
      setIsModalOpen(false);
      setNuevoUser({ nombre: '', email: '', rol: 'operario' });
      fetchData();
    } catch (error) {
      console.error("Error al crear usuario:", error);
    }
  };

  // Función para abrir el modal con un rol predeterminado
  const openModalWithRol = (rol: UserRole) => {
    setNuevoUser({ ...nuevoUser, rol });
    setIsModalOpen(true);
  };

  return (
    <div className="p-6 max-w-6xl mx-auto space-y-8">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Configuración del Sistema</h1>
        <p className="text-gray-500 text-sm">Administra los accesos, clientes y recursos de la imprenta.</p>
      </div>

      {/* Navegación por Pestañas */}
      <div className="flex gap-2 p-1 bg-gray-100 rounded-xl w-fit">
        {(['usuarios', 'clientes', 'maquinas'] as Tab[]).map((tab) => (
          <button
            key={tab}
            onClick={() => setActiveTab(tab)}
            className={cn(
              "px-6 py-2 rounded-lg text-sm font-bold transition-all capitalize",
              activeTab === tab
                ? "bg-white text-blue-600 shadow-sm"
                : "text-gray-500 hover:text-gray-700"
            )}
          >
            {tab}
          </button>
        ))}
      </div>

      {/* CONTENIDO: USUARIOS (Staff/Operarios) */}
      {activeTab === 'usuarios' && (
        <div className="space-y-4 animate-in fade-in duration-300">
          <div className="flex justify-between items-center">
            <h2 className="text-lg font-bold text-gray-800 flex items-center gap-2">
              <Users className="w-5 h-5" /> Staff y Operarios
            </h2>
            <button 
              onClick={() => openModalWithRol('operario')}
              className="flex items-center gap-2 bg-blue-600 text-white px-4 py-2 rounded-xl text-sm font-bold hover:bg-blue-700 transition-colors"
            >
              <UserPlus className="w-4 h-4" /> Nuevo Usuario
            </button>
          </div>

          <div className="bg-white rounded-2xl border border-gray-200 shadow-sm overflow-hidden">
            <table className="w-full text-left border-collapse">
              <thead className="bg-gray-50 text-gray-400 text-[10px] uppercase font-black tracking-widest border-b">
                <tr>
                  <th className="px-6 py-4">Nombre</th>
                  <th className="px-6 py-4">Email</th>
                  <th className="px-6 py-4">Rol</th>
                  <th className="px-6 py-4">Estado</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {usuarios.filter(u => u.rol !== 'cliente').map((u) => (
                  <tr key={u.id} className="hover:bg-gray-50 transition-colors text-sm">
                    <td className="px-6 py-4 font-bold text-gray-900">{u.nombre}</td>
                    <td className="px-6 py-4 text-gray-500">{u.email}</td>
                    <td className="px-6 py-4">
                      <span className={cn(
                        "px-2 py-1 rounded-md text-[10px] font-black uppercase",
                        u.rol === 'admin' ? "bg-purple-100 text-purple-700" : "bg-blue-100 text-blue-700"
                      )}>
                        {u.rol}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <span className="flex items-center gap-1.5 text-green-600 font-medium">
                        <div className="w-1.5 h-1.5 rounded-full bg-green-500" /> Activo
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* CONTENIDO: CLIENTES */}
      {activeTab === 'clientes' && (
        <div className="space-y-6 animate-in fade-in duration-300">
          <div className="flex justify-between items-center">
            <div>
              <h2 className="text-lg font-bold text-gray-800 flex items-center gap-2">
                <Briefcase className="w-5 h-5 text-blue-600" /> Cartera de Clientes
              </h2>
              <p className="text-xs text-gray-400">Gestiona los datos de contacto para la facturación y remitos.</p>
            </div>
            <button 
              onClick={() => openModalWithRol('cliente')}
              className="flex items-center gap-2 bg-emerald-600 text-white px-4 py-2 rounded-xl text-sm font-bold hover:bg-emerald-700 transition-colors"
            >
              <UserPlus className="w-4 h-4" /> Nuevo Cliente
            </button>
          </div>

          <div className="bg-white rounded-2xl border border-gray-200 shadow-sm overflow-hidden">
            <table className="w-full text-left border-collapse">
              <thead className="bg-gray-50 text-gray-400 text-[10px] uppercase font-black tracking-widest border-b">
                <tr>
                  <th className="px-6 py-4">Razón Social / Nombre</th>
                  <th className="px-6 py-4">Contacto Principal</th>
                  <th className="px-6 py-4 text-center">Pedidos Activos</th>
                  <th className="px-6 py-4">Acciones</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {usuarios.filter(u => u.rol === 'cliente').map((cliente) => (
                  <tr key={cliente.id} className="hover:bg-gray-50 transition-colors text-sm">
                    <td className="px-6 py-4 font-bold text-gray-900">{cliente.nombre}</td>
                    <td className="px-6 py-4 text-gray-500">{cliente.email}</td>
                    <td className="px-6 py-4 text-center">
                      <span className="bg-gray-100 px-2 py-1 rounded-md font-mono text-xs text-gray-600">
                        -
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <button className="text-blue-600 hover:underline font-bold text-xs">
                        Ver Historial
                      </button>
                    </td>
                  </tr>
                ))}
                {usuarios.filter(u => u.rol === 'cliente').length === 0 && (
                  <tr>
                    <td colSpan={4} className="px-6 py-10 text-center text-gray-400 text-sm italic">
                      No hay clientes registrados todavía.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* CONTENIDO: MÁQUINAS (Placeholder) */}
      {activeTab === 'maquinas' && (
        <div className="p-12 text-center bg-white rounded-2xl border border-dashed border-gray-300 text-gray-400 animate-in fade-in">
          <Monitor className="w-12 h-12 mx-auto mb-4 opacity-20" />
          <p>Módulo de gestión de maquinaria en desarrollo...</p>
        </div>
      )}

      {/* Modal de Nuevo Usuario / Cliente */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-3xl w-full max-w-md shadow-2xl animate-in zoom-in-95 duration-200">
            <div className="p-6 border-b flex justify-between items-center">
              <h3 className="font-black text-gray-900">
                {nuevoUser.rol === 'cliente' ? 'Registrar Cliente' : 'Registrar Staff'}
              </h3>
              <button onClick={() => setIsModalOpen(false)} className="text-gray-400 hover:text-gray-600">
                <X className="w-6 h-6" />
              </button>
            </div>
            <form onSubmit={handleCrearUsuario} className="p-6 space-y-4">
              <div className="space-y-1">
                <label className="text-xs font-bold text-gray-400 uppercase">
                  {nuevoUser.rol === 'cliente' ? 'Razón Social / Nombre' : 'Nombre Completo'}
                </label>
                <input 
                  required
                  type="text" 
                  value={nuevoUser.nombre}
                  onChange={(e) => setNuevoUser({...nuevoUser, nombre: e.target.value})}
                  className="w-full bg-gray-50 border border-gray-200 rounded-xl px-4 py-3 text-sm focus:ring-2 focus:ring-blue-500 outline-none transition-all"
                  placeholder={nuevoUser.rol === 'cliente' ? "Ej: Editorial Argentina S.A." : "Ej: Juan Pérez"}
                />
              </div>
              <div className="space-y-1">
                <label className="text-xs font-bold text-gray-400 uppercase">Correo Electrónico</label>
                <input 
                  required
                  type="email" 
                  value={nuevoUser.email}
                  onChange={(e) => setNuevoUser({...nuevoUser, email: e.target.value})}
                  className="w-full bg-gray-50 border border-gray-200 rounded-xl px-4 py-3 text-sm focus:ring-2 focus:ring-blue-500 outline-none transition-all"
                  placeholder="ejemplo@correo.com"
                />
              </div>
              <div className="space-y-1">
                <label className="text-xs font-bold text-gray-400 uppercase">Rol en el Sistema</label>
                <select 
                  value={nuevoUser.rol}
                  onChange={(e) => setNuevoUser({...nuevoUser, rol: e.target.value as UserRole})}
                  className="w-full bg-gray-50 border border-gray-200 rounded-xl px-4 py-3 text-sm focus:ring-2 focus:ring-blue-500 outline-none transition-all"
                >
                  <option value="operario">Operario (Staff)</option>
                  <option value="admin">Administrador (Staff)</option>
                  <option value="cliente">Cliente</option>
                </select>
              </div>
              <button 
                type="submit"
                className={cn(
                  "w-full text-white font-bold py-4 rounded-2xl shadow-lg transition-all flex items-center justify-center gap-2 mt-4",
                  nuevoUser.rol === 'cliente' ? "bg-emerald-600 hover:bg-emerald-700 shadow-emerald-100" : "bg-blue-600 hover:bg-blue-700 shadow-blue-200"
                )}
              >
                <Save className="w-5 h-5" /> Guardar {nuevoUser.rol === 'cliente' ? 'Cliente' : 'Usuario'}
              </button>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default Configuracion;