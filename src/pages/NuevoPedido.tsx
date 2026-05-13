import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Save, ArrowLeft, Hash, User, FileText } from 'lucide-react';
import { agregarPedido } from '../services/firestore';
import { APP_CONFIG } from '../config/app.config';

const NuevoPedido = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);

  // Estado para capturar los datos del formulario
  const [formData, setFormData] = useState({
    cliente: '',
    tipo: 'libro',
    cantidad: 100,
    paginas: 50,
    descripcion: ''
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      // Enviamos el objeto a Firestore
      await agregarPedido({
        ...formData,
        estado: 'pendiente',
        prioridad: 'normal',
      });

      navigate('/produccion');
    } catch (error) {
      alert("Error al guardar el pedido. Revisá la consola.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="max-w-2xl mx-auto p-4 lg:p-8">
      <button
        onClick={() => navigate(-1)}
        className="flex items-center text-gray-500 mb-6 hover:text-gray-900 transition-colors"
      >
        <ArrowLeft className="w-4 h-4 mr-2" /> Volver al listado
      </button>

      <div className="bg-white p-8 rounded-3xl shadow-sm border border-gray-100">
        <h1 className="text-2xl font-black mb-8 text-gray-900">Configurar Trabajo</h1>

        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Cliente */}
          <div>
            <label className="flex items-center gap-2 text-xs font-black text-gray-400 uppercase mb-2 ml-1">
              <User className="w-3 h-3" /> Cliente
            </label>
            <input
              required
              value={formData.cliente}
              onChange={(e) => setFormData({...formData, cliente: e.target.value})}
              className="w-full p-4 bg-gray-50 rounded-2xl border-none outline-none focus:ring-2 focus:ring-blue-500 transition-all" 
              placeholder="Nombre de la editorial o cliente"
            />
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* Tipo de Trabajo */}
            <div>
              <label className="flex items-center gap-2 text-xs font-black text-gray-400 uppercase mb-2 ml-1">
                <FileText className="w-3 h-3" /> Tipo de Trabajo
              </label>
              <select
                value={formData.tipo}
                onChange={(e) => setFormData({...formData, tipo: e.target.value})}
                className="w-full p-4 bg-gray-50 rounded-2xl border-none outline-none focus:ring-2 focus:ring-blue-500 appearance-none"
              >
                {Object.keys(APP_CONFIG.merma).map(tipo => (
                  <option key={tipo} value={tipo}>{tipo.toUpperCase()}</option>
                ))}
              </select>
            </div>

            {/* Cantidad */}
            <div>
              <label className="flex items-center gap-2 text-xs font-black text-gray-400 uppercase mb-2 ml-1">
                <Hash className="w-3 h-3" /> Cantidad de Ejemplares
              </label>
              <input
                type="number"
                required
                value={formData.cantidad}
                onChange={(e) => setFormData({...formData, cantidad: Number(e.target.value)})}
                className="w-full p-4 bg-gray-50 rounded-2xl border-none outline-none focus:ring-2 focus:ring-blue-500" 
              />
            </div>
          </div>

          {/* Descripción / Notas */}
          <div>
            <label className="block text-xs font-black text-gray-400 uppercase mb-2 ml-1">Detalles técnicos</label>
            <textarea
              rows={3}
              value={formData.descripcion}
              onChange={(e) => setFormData({...formData, descripcion: e.target.value})}
              placeholder="Ej: Papel obra 80g, tapa dura con laca..."
              className="w-full p-4 bg-gray-50 rounded-2xl border-none outline-none focus:ring-2 focus:ring-blue-500 resize-none"
            />
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-gray-900 text-white p-5 rounded-2xl font-bold hover:bg-black transition-all flex items-center justify-center gap-3 disabled:bg-gray-300"
          >
            {loading ? 'Procesando...' : <><Save className="w-5 h-5" /> Confirmar e Iniciar Pedido</>}
          </button>
        </form>
      </div>
    </div>
  );
};

export default NuevoPedido;