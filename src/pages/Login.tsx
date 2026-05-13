import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { login } from '../services/auth';
import { useAuth } from '../context/AuthContext';
import { Printer, Lock, Mail, AlertCircle, Eye, EyeOff, BookOpen } from 'lucide-react';
import { cn } from '../utils/cn';

export const Login: React.FC = () => {
  const navigate = useNavigate();
  const { refreshUsuario } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      const result = await login(email, password);
      if (result.success && result.user) {
        await refreshUsuario();
        navigate(result.mustChange ? '/cambiar-password' : '/dashboard');
      } else {
        setError(result.error || 'Credenciales incorrectas');
      }
    } catch (err) {
      setError('Error de conexión con el servidor');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="relative min-h-screen flex items-center justify-center overflow-hidden bg-slate-900">

      {/* FONDO ANIMADO: Simulación de Impresión / Offset */}
      <div className="absolute inset-0 z-0">
        <div className="absolute inset-0 bg-linear-to-br from-blue-900/50 via-slate-900 to-purple-900/50" />
        {/* Líneas de "impresión" en movimiento */}
        <div className="absolute inset-0 opacity-20">
          <div className="absolute w-[200%] h-20 bg-blue-500/20 -rotate-45 animate-[print_8s_linear_infinite] top-[-10%]" />
          <div className="absolute w-[200%] h-32 bg-purple-500/10 -rotate-45 animate-[print_12s_linear_infinite] top-[20%]" />
          <div className="absolute w-[200%] h-16 bg-cyan-500/20 -rotate-45 animate-[print_10s_linear_infinite] top-[60%]" />
        </div>
      </div>

      <div className="relative z-10 w-full max-w-md px-6">
        <div className="bg-white/95 backdrop-blur-sm rounded-3xl shadow-2xl p-8 border border-white/20 transform transition-all animate-in fade-in zoom-in duration-500">

          <div className="text-center mb-8">
            <div className="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-blue-600 text-white shadow-lg shadow-blue-200 mb-4 animate-bounce-slow">
              <Printer className="w-8 h-8" />
            </div>
            <h1 className="text-3xl font-black text-gray-900 tracking-tighter">IMPRENTA</h1>
            <p className="text-gray-500 text-sm mt-1">Gestión de Producción y Clientes</p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-5">
            {/* Email */}
            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-1.5 ml-1">Email</label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none">
                  <Mail className="h-5 w-5 text-gray-400" />
                </div>
                <input
                  type="email"
                  required
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="block w-full pl-11 pr-4 py-3 bg-gray-50 border border-gray-200 rounded-xl text-gray-900 focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all outline-none"
                  placeholder="usuario@correo.com"
                />
              </div>
            </div>

            {/* Password */}
            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-1.5 ml-1">Contraseña</label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none">
                  <Lock className="h-5 w-5 text-gray-400" />
                </div>
                <input
                  type={showPassword ? "text" : "password"}
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="block w-full pl-11 pr-12 py-3 bg-gray-50 border border-gray-200 rounded-xl text-gray-900 focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all outline-none"
                  placeholder="••••••••"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute inset-y-0 right-0 pr-3.5 flex items-center text-gray-400 hover:text-blue-600 transition-colors"
                >
                  {showPassword ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
                </button>
              </div>
            </div>

            {error && (
              <div className="flex items-center gap-2 text-red-600 bg-red-50 p-3.5 rounded-xl text-sm border border-red-100 animate-shake">
                <AlertCircle className="h-5 w-5 shrink-0" />
                <span>{error}</span>
              </div>
            )}

            <button
              type="submit"
              disabled={loading}
              className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-3.5 rounded-xl shadow-lg shadow-blue-200 transition-all active:scale-[0.98] disabled:opacity-70 flex items-center justify-center gap-2"
            >
              {loading ? (
                <div className="h-5 w-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
              ) : (
                <>
                  <span>Ingresar al Sistema</span>
                </>
              )}
            </button>
          </form>

          <div className="mt-8 pt-6 border-t border-gray-100">
            <div className="flex justify-center items-center gap-6 text-gray-400">
              <div className="flex items-center gap-1.5 text-xs">
                <div className="w-2 h-2 rounded-full bg-green-500 animate-pulse" />
                Servidor Activo
              </div>
              <div className="flex items-center gap-1.5 text-xs">
                <Lock className="w-3 h-3" />
                AES-256 SSL
              </div>
            </div>
          </div>
        </div>

        <p className="text-center mt-6 text-gray-400 text-xs tracking-widest uppercase">
          © 2026 Sistema de Gestión de Imprentas
        </p>
      </div>

      {/* Estilos para la animación de fondo (Print Effect) */}
      <style>{`
        @keyframes print {
          0% { transform: translateY(-100%) rotate(-45deg); }
          100% { transform: translateY(200%) rotate(-45deg); }
        }
        @keyframes shake {
          0%, 100% { transform: translateX(0); }
          25% { transform: translateX(-4px); }
          75% { transform: translateX(4px); }
        }
        .animate-shake { animation: shake 0.2s ease-in-out 0s 2; }
        .animate-bounce-slow { animation: bounce 3s infinite; }
        @keyframes bounce {
          0%, 100% { transform: translateY(-5%); animation-timing-function: cubic-bezier(0.8, 0, 1, 1); }
          50% { transform: translateY(0); animation-timing-function: cubic-bezier(0, 0, 0.2, 1); }
        }
      `}</style>
    </div>
  );
};

export default Login;