import React from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { UserRole } from '../@types';

interface ProtectedRouteProps {
  children: React.ReactNode;
  allowedRoles?: UserRole[];
  requirePasswordChange?: boolean;
}

export const ProtectedRoute: React.FC<ProtectedRouteProps> = ({
  children,
  allowedRoles,
  requirePasswordChange = false,
}) => {
  const { usuario, loading, isAuthenticated } = useAuth();
  const location = useLocation();

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Cargando sistema...</p>
        </div>
      </div>
    );
  }

  // Si no está autenticado, redirigir al login guardando la ubicación actual
  if (!isAuthenticated) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  // Si requiere cambio de password (primer login) y aún no lo hizo
  if (requirePasswordChange && usuario?.mustChange) {
    return <Navigate to="/cambiar-password" replace />;
  }

  // Si el usuario ya pasó el primer login pero intenta entrar a cambiar-password sin permiso
  if (!requirePasswordChange && usuario?.mustChange) {
    return <Navigate to="/cambiar-password" replace />;
  }

  // Control de acceso por Roles
  if (allowedRoles && usuario && !allowedRoles.includes(usuario.rol)) {
    return <Navigate to="/dashboard" replace />;
  }

  return <>{children}</>;
};

export default ProtectedRoute;