import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { User as FirebaseUser } from 'firebase/auth';
import { Usuario } from '@types';
import { onAuthChange } from '@services/auth';
import { getUsuario } from '@services/firestore';

interface AuthContextType {
  usuario: Usuario | null;
  firebaseUser: FirebaseUser | null;
  loading: boolean;
  isAuthenticated: boolean;
  isAdmin: boolean;
  isOperario: boolean;
  isCliente: boolean;
  refreshUsuario: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [usuario, setUsuario] = useState<Usuario | null>(null);
  const [firebaseUser, setFirebaseUser] = useState<FirebaseUser | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = onAuthChange(async (user) => {
      setFirebaseUser(user);
      if (user) {
        const data = await getUsuario(user.uid);
        setUsuario(data);
      } else {
        setUsuario(null);
      }
      setLoading(false);
    });
    return () => unsubscribe();
  }, []);

  const refreshUsuario = async () => {
    if (firebaseUser) {
      const data = await getUsuario(firebaseUser.uid);
      setUsuario(data);
    }
  };

  const value = {
    usuario,
    firebaseUser,
    loading,
    isAuthenticated: !!usuario && usuario.activo,
    isAdmin: usuario?.rol === 'admin',
    isOperario: usuario?.rol === 'operario',
    isCliente: usuario?.rol === 'cliente',
    refreshUsuario,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth debe usarse dentro de AuthProvider');
  return context;
};