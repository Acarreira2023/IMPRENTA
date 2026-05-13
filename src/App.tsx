import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import { Navbar } from './components/layout/Navbar';
import { ProtectedRoute } from './components/ProtectedRoute';

// Páginas
import Login from './pages/Login';
import CambiarPassword from './pages/CambiarPassword';
import Dashboard from './pages/Dashboard';
import Pedidos from './pages/Pedidos';
import NuevoPedido from './pages/NuevoPedido';
import Produccion from './pages/Produccion';
import Usuarios from './pages/Usuarios';
import Configuracion from './pages/Configuracion';

// Layout que envuelve las páginas protegidas
const AppLayout: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  return (
    <div className="min-h-screen bg-gray-50">
      <Navbar />
      <main className="container mx-auto px-4 py-8">
        {children}
      </main>
    </div>
  );
};

const App: React.FC = () => {
  return (
    <BrowserRouter>
      <AuthProvider>
        <Routes>
          {/* Rutas Públicas */}
          <Route path="/login" element={<Login />} />

          {/* Ruta Especial: Cambio de Password Obligatorio */}
          <Route
            path="/cambiar-password"
            element={
              <ProtectedRoute requirePasswordChange>
                <CambiarPassword />
              </ProtectedRoute>
            }
          />

          {/* Rutas Privadas Protegidas */}
          <Route
            path="/*"
            element={
              <ProtectedRoute>
                <AppLayout>
                  <Routes>
                    <Route path="dashboard" element={<Dashboard />} />
                    <Route path="pedidos" element={<Pedidos />} />
                    <Route path="nuevo-pedido" element={<NuevoPedido />} />

                    {/* Solo Admin y Operario ven Producción */}
                    <Route
                      path="produccion"
                      element={
                        <ProtectedRoute allowedRoles={['admin', 'operario','usuario']}>
                          <Produccion />
                        </ProtectedRoute>
                      }
                    />

                    {/* Solo Admin ve Usuarios y Configuración */}
                    <Route
                      path="usuarios"
                      element={
                        <ProtectedRoute allowedRoles={['admin']}>
                          <Usuarios />
                        </ProtectedRoute>
                      }
                    />
                    <Route
                      path="configuracion"
                      element={
                        <ProtectedRoute allowedRoles={['admin']}>
                          <Configuracion />
                        </ProtectedRoute>
                      }
                    />

                    {/* Redirección por defecto al Dashboard */}
                    <Route path="*" element={<Navigate to="/dashboard" replace />} />
                  </Routes>
                </AppLayout>
              </ProtectedRoute>
            }
          />
        </Routes>
      </AuthProvider>
    </BrowserRouter>
  );
};

export default App;