import React, { useEffect, useState } from 'react';
import { useAuth } from '@context/AuthContext';
import { getKpis, getPedidos, getAlertas } from '@services/firestore';
import { KpiData, Pedido, Alerta } from '../@types';
import { KpiCard } from '@components/KpiCard';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  Legend,
} from 'recharts';
import { 
  Package, 
  Clock, 
  CheckCircle, 
  AlertTriangle, 
  TrendingUp,
  Bell
} from 'lucide-react';

const COLORS = ['#3B82F6', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6'];

export const Dashboard: React.FC = () => {
  const { usuario } = useAuth();
  const [kpis, setKpis] = useState<KpiData | null>(null);
  const [pedidos, setPedidos] = useState<Pedido[]>([]);
  const [alertas, setAlertas] = useState<Alerta[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadDashboardData = async () => {
      try {
        const [kpiData, pedidosData, alertasData] = await Promise.all([
          getKpis(),
          getPedidos(),
          getAlertas()
        ]);
        setKpis(kpiData);
        setPedidos(pedidosData);
        setAlertas(alertasData.filter(a => !a.leida));
      } catch (error) {
        console.error("Error al cargar dashboard:", error);
      } finally {
        setLoading(false);
      }
    };
    loadDashboardData();
  }, []);

  if (loading) return <div className="p-8 text-center">Cargando métricas...</div>;

  // Datos para el gráfico de torta (Estado de Pedidos)
  const chartData = [
    { name: 'Pendientes', value: kpis?.pedidosPendientes || 0 },
    { name: 'En Proceso', value: kpis?.pedidosEnProceso || 0 },
    { name: 'Completados', value: kpis?.pedidosCompletados || 0 },
  ];

  return (
    <div className="p-6 max-w-7xl mx-auto space-y-8">
      {/* Cabecera */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Bienvenido, {usuario?.nombre}</h1>
        <p className="text-gray-500">Este es el estado actual de la producción.</p>
      </div>

      {/* Grilla de KPIs */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <KpiCard 
          title="Pedidos Totales" 
          value={kpis?.pedidosTotales || 0} 
          icon={Package} 
          color="blue" 
          trend={{ value: 12, positive: true }}
        />
        <KpiCard 
          title="En Producción" 
          value={kpis?.pedidosEnProceso || 0} 
          icon={Clock} 
          color="orange" 
        />
        <KpiCard 
          title="Mermas" 
          value={`${kpis?.mermaTotal || 0} u.`} 
          icon={AlertTriangle} 
          color="red" 
        />
        <KpiCard 
          title="Entregados" 
          value={kpis?.pedidosEntregados || 0} 
          icon={CheckCircle} 
          color="green" 
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Gráfico de Barras - Producción Semanal */}
        <div className="lg:col-span-2 bg-white p-6 rounded-2xl border border-gray-200 shadow-sm">
          <div className="flex items-center justify-between mb-6">
            <h3 className="font-bold text-gray-800 flex items-center gap-2">
              <TrendingUp className="w-5 h-5 text-blue-500" />
              Producción Semanal
            </h3>
          </div>
          <div className="h-80 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={pedidos.slice(0, 7)}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f0f0f0" />
                <XAxis dataKey="numeroPedido" hide />
                <YAxis />
                <Tooltip 
                  cursor={{fill: '#f8fafc'}}
                  contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 10px 15px -3px rgba(0,0,0,0.1)' }}
                />
                <Bar dataKey="cantidadOriginal" fill="#3B82F6" radius={[4, 4, 0, 0]} barSize={40} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Gráfico de Torta - Estados */}
        <div className="bg-white p-6 rounded-2xl border border-gray-200 shadow-sm">
          <h3 className="font-bold text-gray-800 mb-6">Distribución de Estados</h3>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={chartData}
                  innerRadius={60}
                  outerRadius={80}
                  paddingAngle={5}
                  dataKey="value"
                >
                  {chartData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip />
                <Legend verticalAlign="bottom" height={36}/>
              </PieChart>
            </ResponsiveContainer>
          </div>
          <div className="mt-4 space-y-2">
            {alertas.length > 0 && (
              <div className="p-3 bg-red-50 rounded-xl border border-red-100 flex items-center gap-3">
                <Bell className="w-5 h-5 text-red-500 animate-ring" />
                <span className="text-sm text-red-700 font-medium">Tienes {alertas.length} alertas activas</span>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;