import React, { createContext, useContext, useState, useEffect } from 'react';
import { login as authLogin, logout as authLogout, onAuthChange } from '../services/auth.js';
import { getUsuario } from '../services/firestore.js';

const AuthContext = createContext();

export function AuthProvider({ children }) {
  const [user, setUser] = useState(() => {
    // Intentar recuperar sesión persistente al recargar la página
    const savedSession = localStorage.getItem('imprenta_session');
    return savedSession ? JSON.parse(savedSession) : null;
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Escucha cambios reales de Firebase Cloud (solo si no es usuario demo)
    const unsubscribe = onAuthChange(async (firebaseUser) => {
      if (firebaseUser && (!user || !user.isDemo)) {
        try {
          const datosExtra = await getUsuario(firebaseUser.uid);
          const usuarioCompleto = {
            uid: firebaseUser.uid,
            email: firebaseUser.email,
            isDemo: false,
            ...datosExtra
          };
          setUser(usuarioCompleto);
          localStorage.setItem('imprenta_session', JSON.stringify(usuarioCompleto));
        } catch (err) {
          console.error("Error al sincronizar usuario de Firestore:", err);
        }
      }
      setLoading(false);
    });

    // Si hay una sesión demo en el LocalStorage, quitamos el loading de inmediato
    if (user?.isDemo) {
      setLoading(false);
    }

    return () => unsubscribe();
  }, [user]);

  // Función de Login Unificada
  const login = async (email, password) => {
    const resultado = await authLogin(email, password);
    if (resultado.success) {
      setUser(resultado.user);
      localStorage.setItem('imprenta_session', JSON.stringify(resultado.user));
      return resultado.user;
    } else {
      throw new Error(resultado.error);
    }
  };

  // Función de Cierre de Sesión
  const logout = async () => {
    if (user && !user.isDemo) {
      await authLogout();
    }
    setUser(null);
    localStorage.removeItem('imprenta_session');
  };

  // Conmutador rápido para la consola de desarrollo en el Navbar
  const changeRoleDevMode = (nuevoRol, esDemo = true) => {
    const usuarioModificado = {
      uid: esDemo ? `demo_${Date.now()}` : (user?.uid || 'real_dev_uid'),
      email: esDemo ? `${nuevoRol.toLowerCase()}@demo.com` : (user?.email || 'admin@empresa.com'),
      role: nuevoRol,
      rol: nuevoRol,
      name: `Dev Mode (${nuevoRol.toLowerCase()})`,
      isDemo: esDemo
    };
    setUser(usuarioModificado);
    localStorage.setItem('imprenta_session', JSON.stringify(usuarioModificado));
  };

  return (
    <AuthContext.Provider value={{ user, login, logout, changeRoleDevMode, loading }}>
      {!loading && children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  return useContext(AuthContext);
}