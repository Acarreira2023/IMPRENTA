import React, { useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { cn } from '../../utils/cn';
import { useAuth } from '../../context/AuthContext';
import { logout } from '../../services/auth';
import {
  LayoutDashboard,
  Package,
  Settings,
  Users,
  LogOut,
  Menu,
  X,
  Printer,
  FileText,
  BookOpen
} from 'lucide-react';

interface NavItem {
  path: string;
  label: string;
  icon: React.ElementType;
  roles: ('admin' | 'operario' | 'cliente')[];
}

const navItems: NavItem[] = [
  { path: '/dashboard', label: 'Dashboard', icon: LayoutDashboard, roles: ['admin', 'operario'] },
  { path: '/pedidos', label: 'Mis Pedidos', icon: Package, roles: ['admin', 'operario', 'cliente'] },
  { path: '/produccion', label: 'Producción', icon: Printer, roles: ['admin', 'operario'] },
  { path: '/reportes', label: 'Reportes', icon: FileText, roles: ['admin'] },
  { path: '/usuarios', label: 'Usuarios', icon: Users, roles: ['admin'] },
  { path: '/configuracion', label: 'Configuración', icon: Settings, roles: ['admin'] },
];

export const Navbar: React.FC = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const { usuario, isAdmin } = useAuth();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  const handleLogout = async () => {
    await logout();
    navigate('/login');
  };

  // Filtramos los items según el rol del usuario actual
  const filteredItems = navItems.filter(item => 
    usuario && item.roles.includes(usuario.rol)
  );

  return (
    <nav className="bg-white border-b border-gray-200 sticky top-0 z-40">
      <div className="container mx-auto px-4">
        <div className="flex justify-between h-16">
          <div className="flex items-center">
            <Link to="/dashboard" className="flex items-center gap-2">
              <div className="bg-blue-600 p-1.5 rounded-lg">
                <BookOpen className="w-6 h-6 text-white" />
              </div>
              <span className="text-xl font-bold text-gray-900 tracking-tight">
                IMPRENTA
              </span>
            </Link>
            
            {/* Navegación Desktop */}
            <div className="hidden md:ml-8 md:flex md:space-x-1">
              {filteredItems.map((item) => {
                const Icon = item.icon;
                const isActive = location.pathname === item.path;
                return (
                  <Link
                    key={item.path}
                    to={item.path}
                    className={cn(
                      "flex items-center px-3 py-2 rounded-md text-sm font-medium transition-colors",
                      isActive 
                        ? "bg-blue-50 text-blue-700" 
                        : "text-gray-600 hover:bg-gray-50 hover:text-gray-900"
                    )}
                  >
                    <Icon className="w-4 h-4 mr-2" />
                    {item.label}
                  </Link>
                );
              })}
            </div>
          </div>

          {/* Usuario y Logout */}
          <div className="hidden md:flex items-center gap-4">
            <div className="text-right mr-2">
              <p className="text-sm font-semibold text-gray-900 leading-none">{usuario?.nombre}</p>
              <p className="text-xs text-gray-500 capitalize">{usuario?.rol}</p>
            </div>
            <button
              onClick={handleLogout}
              className="p-2 text-gray-500 hover:text-red-600 hover:bg-red-50 rounded-full transition-all"
              title="Cerrar sesión"
            >
              <LogOut className="w-5 h-5" />
            </button>
          </div>

          {/* Botón Móvil */}
          <div className="flex items-center md:hidden">
            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="p-2 rounded-md text-gray-600 hover:bg-gray-100"
            >
              {mobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
            </button>
          </div>
        </div>
      </div>

      {/* Menú Móvil */}
      {mobileMenuOpen && (
        <div className="md:hidden bg-white border-b border-gray-200 py-2 px-4 space-y-1">
          {filteredItems.map((item) => (
            <Link
              key={item.path}
              to={item.path}
              onClick={() => setMobileMenuOpen(false)}
              className="flex items-center px-3 py-3 rounded-md text-base font-medium text-gray-700 hover:bg-gray-50"
            >
              <item.icon className="w-5 h-5 mr-3 text-gray-500" />
              {item.label}
            </Link>
          ))}
          <button
            onClick={handleLogout}
            className="w-full flex items-center px-3 py-3 rounded-md text-base font-medium text-red-600 hover:bg-red-50"
          >
            <LogOut className="w-5 h-5 mr-3" />
            Cerrar Sesión
          </button>
        </div>
      )}
    </nav>
  );
};