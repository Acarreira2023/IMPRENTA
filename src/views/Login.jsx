import React, { useState } from 'react';
import { useAuth } from '../context/AuthContext.jsx';
import { Printer, Lock, Mail, Eye, EyeOff } from 'lucide-react';

export const Login = ({ onLoginSuccess }) => {
  const { login } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      await login(email, password);
      if (onLoginSuccess) {
        onLoginSuccess();
      }
    } catch (err) {
      console.error(err);
      setError('Credenciales inválidas o error de conexión con Firebase.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-container animate-fadeIn">
      <div className="login-card">
        {/* Icono Principal */}
        <div className="login-logo">
          <Printer />
        </div>
        
        {/* Título y Subtítulo */}
        <div className="login-header">
          <h1 className="login-title">IMPRENTA</h1>
          <p className="login-subtitle">Sistema de Gestión de Production</p>
        </div>

        {/* Formulario Estricto y Cerrado */}
        <form onSubmit={handleSubmit} className="login-form">
          <div className="form-group">
            <label className="form-label">Correo Electrónico</label>
            <div className="input-wrapper">
              <span className="input-icon"><Mail size={16} /></span>
              <input
                type="email"
                className="login-input"
                placeholder="usuario@empresa.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>
          </div>

          <div className="form-group">
            <label className="form-label">Contraseña</label>
            <div className="input-wrapper">
              <span className="input-icon"><Lock size={16} /></span>
              <input
                type={showPassword ? "text" : "password"}
                className="login-input"
                placeholder="••••••••"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                style={{
                  position: 'absolute',
                  right: '14px',
                  top: '50%',
                  transform: 'translateY(-50%)',
                  color: '#94a3b8',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center' // Corregido camelCase para compatibilidad de estilos en línea de React
                }}
              >
                {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
              </button>
            </div>
          </div>

          <p className="text-[10px] text-slate-400 bg-slate-50 p-2 rounded-lg border border-slate-100 italic">
            💡 Tip: Usá cualquier clave y un correo <span className="font-bold text-amber-600">@demo.com</span> para modo emulado.
          </p>

          {error && (
            <div style={{
              color: '#dc2626',
              backgroundColor: '#fef2f2',
              border: '1px solid #fee2e2',
              borderRadius: '8px',
              padding: '10px',
              fontSize: '12px',
              textAlign: 'center',
              fontWeight: 500
            }}>
              {error}
            </div>
          )}

          <button type="submit" className="login-button" disabled={loading}>
            {loading ? "Verificando..." : "Ingresar al Sistema"}
          </button>
        </form>

        {/* Separador fuera del form */}
        <div className="separator"></div>

        {/* Sección de Seguridad */}
        <div className="security-section">
          <span className="security-label">Seguridad de la Cuenta</span>
          <ul className="security-list">
            <li className="security-item">
              <span className="security-icon">✓</span>
              Conexión cifrada de extremo a extremo.
            </li>
          </ul>
        </div>

        {/* Footer */}
        <div className="login-footer" style={{ textAlign: 'center' }}>
          <p className="login-footer-text">© 2026 Sistema de Gestión de Imprentas</p>
          <p style={{ 
            fontSize: '10px', 
            color: '#94a3b8', 
            marginTop: '4px', 
            fontWeight: '500',
            letterSpacing: '0.025em'
          }}>
            Creado por <span style={{ color: '#64748b', fontWeight: '600' }}>Aníbal Carreira</span>
          </p>
        </div>
      </div>
    </div>
  );
};

export default Login;