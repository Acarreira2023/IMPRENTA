import React, { useState } from 'react';
import { AuthProvider, useAuth } from './context/AuthContext';
import Navbar from './components/Navbar.jsx';
import Sidebar from './components/Sidebar.jsx';
import Login from './views/Login.jsx';
import Dashboard from './views/Dashboard.jsx';
import Pedidos from './views/Pedidos.jsx';
import Produccion from './views/Produccion.jsx';
import Reportes from './views/Reportes.jsx';

function ContenidoAplicacion() {
  const { user } = useAuth();
  const [currentView, setCurrentView] = useState('dashboard');

  // Si no hay sesión iniciada (ni real ni demo), se bloquea la app y muestra el Login
  if (!user) {
    return <Login onLoginSuccess={() => setCurrentView('dashboard')} />;
  }

  const renderView = () => {
    switch (currentView) {
      case 'dashboard': return <Dashboard />;
      case 'pedidos': return <Pedidos />;
      case 'produccion': return <Produccion />;
      case 'reportes': return <Reportes />;
      default: return <Dashboard />;
    }
  };

  return (
    <div className="flex h-screen bg-slate-50 overflow-hidden">
      <Sidebar currentView={currentView} setCurrentView={setCurrentView} />
      <div className="flex-1 flex flex-col overflow-hidden">
        <Navbar />
        <main className="flex-1 overflow-y-auto p-4 md:p-6 max-w-[1600px] w-full mx-auto">
          {renderView()}
        </main>
      </div>
    </div>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <ContenidoAplicacion />
    </AuthProvider>
  );
}