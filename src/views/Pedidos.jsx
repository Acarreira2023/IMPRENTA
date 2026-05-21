import React, { useState, useEffect } from 'react';
import FormularioPedido from './FormularioPedido';
import { useAuth } from '../context/AuthContext';
import { db } from '../firebase';
import { collection, onSnapshot, doc, setDoc } from 'firebase/firestore';

export default function Pedidos() {
  const { user } = useAuth();
  const [orders, setOrders] = useState([]);
  const [isEditing, setIsEditing] = useState(false);
  const [currentOrder, setCurrentOrder] = useState(null);
  const [loading, setLoading] = useState(true);

  const demoMockData = [
    { id: 'PED-DEMO-001', client: 'Cliente de Prueba S.A.', description: 'Folletería de Demostración', quantity: 2500, status: 'En Proceso', stages: { ingreso: { date: '20/05/2026' } } },
    { id: 'PED-DEMO-002', client: 'Mi Empresa Test', description: 'Tarjetas de presentación Mate', quantity: 200, status: 'Pendiente', stages: { ingreso: { date: '20/05/2026' } } }
  ];

  useEffect(() => {
    if (user?.isDemo) {
      setOrders(demoMockData);
      setLoading(false);
      return;
    }

    const ordersCollection = collection(db, 'pedidos');
    const unsubscribe = onSnapshot(ordersCollection, (snapshot) => {
      const ordersData = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      setOrders(user?.role === 'CLIENTE' ? ordersData.filter(o => o.client === user.name) : ordersData);
      setLoading(false);
    }, () => {
      setOrders(demoMockData);
      setLoading(false);
    });

    return unsubscribe;
  }, [user]);

  const handleOpenCreate = () => {
    setCurrentOrder(null);
    setIsEditing(true);
  };

  const handleSave = async (savedOrder) => {
    if (user?.isDemo) {
      setOrders(orders.some(o => o.id === savedOrder.id) ? orders.map(o => o.id === savedOrder.id ? savedOrder : o) : [...orders, savedOrder]);
      setIsEditing(false);
      return;
    }
    try {
      await setDoc(doc(db, 'pedidos', savedOrder.id), savedOrder);
      setIsEditing(false);
    } catch (error) {
      alert("Error al persistir en la nube.");
    }
  };

  if (loading) return <p className="text-xs font-mono p-6 text-slate-400">Sincronizando entorno seguro de datos...</p>;

  return (
    <div className="space-y-6 animate-fadeIn">
      <div className={`p-3 rounded-xl border flex justify-between items-center ${user?.isDemo ? 'bg-amber-500/10 border-amber-500/20 text-amber-800' : 'bg-emerald-500/10 border-emerald-500/20 text-emerald-800'}`}>
        <span className="text-xs font-bold">{user?.isDemo ? '⚠️ MÓDULO SANDBOX (DEMO)' : '🟢 ENTORNO DE PRODUCCIÓN CLOUD'}</span>
      </div>
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-xl md:text-2xl font-bold text-slate-900">Gestión de Pedidos</h1>
        </div>
        {user?.role === 'ADMINISTRADOR' && <button onClick={handleOpenCreate} className="px-4 py-2 bg-orange-500 text-white font-bold text-xs rounded-xl shadow-sm">+ Registrar Orden</button>}
      </div>
      {isEditing ? (
        <FormularioPedido order={currentOrder} onSave={handleSave} onCancel={() => setIsEditing(false)} />
      ) : (
        <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
          <table className="w-full text-left border-collapse text-xs">
            <thead>
              <tr className="bg-slate-50 border-b border-slate-200 text-[10px] font-bold text-slate-500 uppercase tracking-wider"><th className="p-4">ID</th><th className="p-4">Cliente</th><th className="p-4">Trabajo</th><th className="p-4">Tirada</th><th className="p-4">Estado</th>{user?.role === 'ADMINISTRADOR' && <th className="p-4 text-center">Acción</th>}</tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {orders.map(order => (
                <tr key={order.id} className="hover:bg-slate-50/50">
                  <td className="p-4 font-mono font-bold text-orange-500">{order.id}</td>
                  <td className="p-4 font-semibold text-slate-800">{order.client}</td>
                  <td className="p-4 text-slate-600">{order.description}</td>
                  <td className="p-4 font-mono">{order.quantity.toLocaleString()} un.</td>
                  <td className="p-4"><span className="px-2 py-0.5 rounded-md font-bold text-[10px] bg-amber-100 text-amber-800">{order.status}</span></td>
                  {user?.role === 'ADMINISTRADOR' && <td className="p-4 text-center"><button onClick={() => { setCurrentOrder(order); setIsEditing(true); }} className="px-2.5 py-1 text-[11px] font-bold text-slate-700 bg-white border border-slate-200 rounded-lg">Modificar</button></td>}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}