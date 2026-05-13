import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { User as FirebaseUser, onAuthStateChanged } from 'firebase/auth';
import { auth } from '../services/firebase'; // Exportar 'auth' desde tu configuración de Firebase
import { Usuario } from '../types';
import { getUsuario } from '../services/firestore'; // Función para obtener datos adicionales del usuario desde Firestore

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
    // Usamos el listener directo de Firebase Auth
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      setFirebaseUser(user);

      if (user) {
        try {
          // Buscamos el perfil completo en Firestore
          const data = await getUsuario(user.uid);
          setUsuario(data || null);
        } catch (error) {
          console.error("Error al obtener usuario de Firestore:", error);
          setUsuario(null);
        }
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
      setUsuario(data || null);
    }
  };

  const value = {
    usuario,
    firebaseUser,
    loading,
    // Autenticado si existe usuario de Firebase Y existe el registro en tu BD
    isAuthenticated: !!firebaseUser && !!usuario,
    isAdmin: usuario?.rol === 'admin',
    isOperario: usuario?.rol === 'operario',
    isCliente: usuario?.rol === 'cliente',
    refreshUsuario,
  };

  return (
    <AuthContext.Provider value={value}>
      {!loading && children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth debe usarse dentro de AuthProvider');
  return context;
};