import React, { useEffect, useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { getPedidos, actualizarPedido } from '../services/firestore';
import { Pedido, EtapaNombre, SubProducto } from '../types';
import { cn, formatDateTime } from '../utils/cn';
import {
  Printer,
  BookOpen,
  Play,
  CheckCircle2,
  Clock,
  Layers,
  ChevronDown,
  ChevronUp
} from 'lucide-react';

export const Produccion: React.FC = () => {
  const { usuario } = useAuth();
  const [pedidos, setPedidos] = useState<Pedido[]>([]);
  const [loading, setLoading] = useState(true);
  const [expandedId, setExpandedId] = useState<string | null>(null);

  useEffect(() => {
    fetchProduccion();
  }, []);

  const fetchProduccion = async () => {
    const data = await getPedidos();
    // Filtramos los que están en proceso o listos para arrancar
    setPedidos(data.filter(p => p.estado === 'en_proceso' || p.estado === 'pendiente'));
    setLoading(false);
  };

  const handleToggleEtapa = async (pedidoId: string, etapa: EtapaNombre, sub?: SubProducto, accion: 'inicio' | 'fin' = 'inicio') => {
    const pedido = pedidos.find(p => p.id === pedidoId);
    if (!pedido || !usuario) return;

    const nuevasEtapas = { ...pedido.etapas };
    const ahora = new Date();

    if (etapa === 'impresion' || etapa === 'encuadernacion') {
      if (sub) {
        // @ts-ignore - Acceso dinámico a etapas con subproductos
        nuevasEtapas[etapa][sub][accion] = ahora;
        // @ts-ignore
        if (accion === 'inicio') nuevasEtapas[etapa][sub].usuarioId = usuario.id;
      }
    } else {
      // @ts-ignore - Etapas simples
      nuevasEtapas[etapa][accion] = ahora;
    }

    try {
      await actualizarPedido(pedidoId, {
        etapas: nuevasEtapas,
        estado: 'en_proceso',
        updatedAt: ahora
      });
      fetchProduccion(); // Refrescar lista
    } catch (error) {
      console.error("Error al actualizar producción:", error);
    }
  };

  if (loading) return <div className="p-10 text-center">Cargando línea de producción...</div>;

  return (
    <div className="p-6 max-w-7xl mx-auto space-y-6">
      <div className="flex justify-between items-end border-b pb-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Panel de Operaciones</h1>
          <p className="text-gray-500">Gestión de etapas: Interior y Tapa.</p>
        </div>
      </div>

      <div className="space-y-4">
        {pedidos.map((pedido) => (
          <div key={pedido.id} className="bg-white rounded-2xl border border-gray-200 shadow-sm overflow-hidden transition-all">
            {/* Header del Pedido */}
            <div
              className="p-5 flex items-center justify-between cursor-pointer hover:bg-gray-50"
              onClick={() => setExpandedId(expandedId === pedido.id ? null : pedido.id)}
            >
              <div className="flex items-center gap-4">
                <div className="bg-blue-100 p-3 rounded-xl text-blue-700">
                  <Printer className="w-6 h-6" />
                </div>
                <div>
                  <div className="flex items-center gap-2">
                    <span className="text-sm font-black text-blue-600">#{pedido.numeroPedido}</span>
                    <span className="px-2 py-0.5 rounded-md bg-gray-100 text-[10px] font-bold uppercase text-gray-500">
                      {pedido.estado}
                    </span>
                  </div>
                  <h3 className="font-bold text-gray-900">{pedido.clienteNombre}</h3>
                </div>
              </div>

              <div className="flex items-center gap-6">
                <div className="hidden md:block text-right">
                  <p className="text-xs text-gray-400 uppercase font-bold">Cantidad</p>
                  <p className="font-bold text-gray-900">{pedido.cantidadOriginal} u.</p>
                </div>
                {expandedId === pedido.id ? <ChevronUp /> : <ChevronDown />}
              </div>
            </div>

            {/* Detalle de Etapas (Acordeón) */}
            {expandedId === pedido.id && (
              <div className="p-6 bg-gray-50 border-t border-gray-100 animate-in slide-in-from-top-2">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-8">

                  {/* COLUMNA 1: IMPRESIÓN */}
                  <div className="space-y-4">
                    <h4 className="flex items-center gap-2 font-bold text-gray-700 pb-2 border-b">
                      <Layers className="w-4 h-4" /> Impresión
                    </h4>

                    {/* Sub-item Interior */}
                    <div className="bg-white p-4 rounded-xl border border-gray-200 flex items-center justify-between">
                      <div>
                        <p className="text-sm font-bold text-gray-800">Interior</p>
                        <p className="text-[10px] text-gray-400">
                          {pedido.etapas.impresion.interior.inicio ? `Iniciado: ${formatDateTime(pedido.etapas.impresion.interior.inicio)}` : 'Sin iniciar'}
                        </p>
                      </div>
                      {!pedido.etapas.impresion.interior.inicio ? (
                        <button
                          onClick={() => handleToggleEtapa(pedido.id, 'impresion', 'interior', 'inicio')}
                          className="flex items-center gap-2 bg-blue-600 text-white px-4 py-2 rounded-lg text-xs font-bold hover:bg-blue-700"
                        >
                          <Play className="w-3 h-3 fill-current" /> Iniciar
                        </button>
                      ) : !pedido.etapas.impresion.interior.fin ? (
                        <button
                          onClick={() => handleToggleEtapa(pedido.id, 'impresion', 'interior', 'fin')}
                          className="flex items-center gap-2 bg-green-600 text-white px-4 py-2 rounded-lg text-xs font-bold hover:bg-green-700"
                        >
                          <CheckCircle2 className="w-3 h-3" /> Finalizar
                        </button>
                      ) : (
                        <span className="text-green-600"><CheckCircle2 /></span>
                      )}
                    </div>

                    {/* Sub-item Tapa */}
                    <div className="bg-white p-4 rounded-xl border border-gray-200 flex items-center justify-between">
                      <div>
                        <p className="text-sm font-bold text-gray-800">Tapa</p>
                        <p className="text-[10px] text-gray-400">
                          {pedido.etapas.impresion.tapa.inicio ? `Iniciado: ${formatDateTime(pedido.etapas.impresion.tapa.inicio)}` : 'Sin iniciar'}
                        </p>
                      </div>
                      {!pedido.etapas.impresion.tapa.inicio ? (
                        <button
                          onClick={() => handleToggleEtapa(pedido.id, 'impresion', 'tapa', 'inicio')}
                          className="flex items-center gap-2 bg-blue-600 text-white px-4 py-2 rounded-lg text-xs font-bold hover:bg-blue-700"
                        >
                          <Play className="w-3 h-3 fill-current" /> Iniciar
                        </button>
                      ) : !pedido.etapas.impresion.tapa.fin ? (
                        <button
                          onClick={() => handleToggleEtapa(pedido.id, 'impresion', 'tapa', 'fin')}
                          className="flex items-center gap-2 bg-green-600 text-white px-4 py-2 rounded-lg text-xs font-bold hover:bg-green-700"
                        >
                          <CheckCircle2 className="w-3 h-3" /> Finalizar
                        </button>
                      ) : (
                        <span className="text-green-600"><CheckCircle2 /></span>
                      )}
                    </div>
                  </div>

                  {/* COLUMNA 2: ENCUADERNACIÓN */}
                  <div className="space-y-4">
                    <h4 className="flex items-center gap-2 font-bold text-gray-700 pb-2 border-b">
                      <BookOpen className="w-4 h-4" /> Encuadernación
                    </h4>
                    {/* Aquí repetirías la lógica similar para Encuadernación */}
                    <p className="text-xs text-gray-400 italic">Pendiente de habilitar según fin de impresión...</p>
                  </div>

                </div>
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
};

export default Produccion;