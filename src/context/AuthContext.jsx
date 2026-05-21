import React, { createContext, useContext, useState, useEffect } from 'react';
import { auth, db } from '../firebase';
import { onAuthStateChanged, signInWithEmailAndPassword, signOut } from 'firebase/auth';
import { doc, getDoc } from 'firebase/firestore';

const AuthContext = createContext();

export function AuthProvider({ children }) {

  const [user, setUser] = useState(null);

  const [loading, setLoading] = useState(false);

  const login = async (email, password) => {
    if (email.endsWith('@demo.com')) {
      const role = email.includes('admin') ? 'ADMINISTRADOR' : email.includes('operario') ? 'OPERARIO' : 'CLIENTE';
      const demoUser = {
        uid: `demo_${Date.now()}`,
        email: email,
        role: role,
        name: `Usuario Demo (${role.toLowerCase()})`,
        isDemo: true
      };
      setUser(demoUser);
      return demoUser;
    }
    return signInWithEmailAndPassword(auth, email, password);
  };

  const logout = () => {
    if (user?.isDemo) {
      setUser(null);
      return;
    }
    return signOut(auth);
  };

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (firebaseUser) => {
      if (firebaseUser) {
        try {
          const userDoc = await getDoc(doc(db, 'usuarios', firebaseUser.uid));
          if (userDoc.exists()) {
            setUser({
              uid: firebaseUser.uid,
              email: firebaseUser.email,
              isDemo: false,
              ...userDoc.data()
            });
          } else {
            setUser({ uid: firebaseUser.uid, email: firebaseUser.email, role: 'CLIENTE', isDemo: false });
          }
        } catch (e) {
          console.error("Error leyendo perfil de Firebase Firestore", e);
        }
      } else {
        setUser((prev) => (prev?.isDemo ? prev : null));
      }
    });

    return unsubscribe;
  }, []);

  const changeRoleDevMode = (newRole, forceDemo = true) => {
    setUser({
      uid: forceDemo ? `demo_${Date.now()}` : 'real_user_dev',
      email: `${newRole.toLowerCase()}@${forceDemo ? 'demo.com' : 'imprenta.com'}`,
      role: newRole,
      name: forceDemo ? `Demo Local - ${newRole}` : `Operación Real - ${newRole}`,
      isDemo: forceDemo
    });
  };

  return (
    <AuthContext.Provider value={{ user, login, logout, changeRoleDevMode }}>
      {!loading && children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);