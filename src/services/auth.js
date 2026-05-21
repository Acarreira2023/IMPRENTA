import { signInWithEmailAndPassword, signOut, onAuthStateChanged } from 'firebase/auth';
import { auth } from './firebase';
import { getUsuario } from './firestore';

/**
 * Lógica de inicio de sesión híbrida (Soporta Sandbox Local y Cloud Real)
 */
export const login = async (email, password) => {
  // 1. Interceptor para el entorno Demo en memoria (sin conexión a internet)
  if (email.endsWith('@demo.com')) {
    const role = email.includes('admin') ? 'ADMINISTRADOR' : email.includes('operario') ? 'OPERARIO' : 'CLIENTE';
    const demoUser = {
      uid: `demo_${Date.now()}`,
      email: email,
      role: role,
      name: `Usuario Demo (${role.toLowerCase()})`,
      isDemo: true,
      mustChangePassword: false
    };
    
    return {
      success: true,
      user: demoUser,
      mustChange: false
    };
  }

  // 2. Flujo de autenticación Real con Firebase Cloud
  try {
    const userCredential = await signInWithEmailAndPassword(auth, email, password);
    const usuario = await getUsuario(userCredential.user.uid);

    return {
      success: true,
      user: {
        uid: userCredential.user.uid,
        email: userCredential.user.email,
        isDemo: false,
        ...usuario
      },
      mustChange: usuario?.mustChangePassword || false
    };
  } catch (error) {
    console.error("Error en Firebase Auth real:", error);
    return { 
      success: false, 
      error: error.code === 'auth/invalid-credential' 
        ? 'Credenciales inválidas en el sistema cloud.' 
        : 'Error de conexión con la base de datos de la imprenta.' 
    };
  }
};

/**
 * Cierre de sesión de Firebase
 */
export const logout = () => signOut(auth);

/**
 * Escuchador del estado de autenticación nativo
 */
export const onAuthChange = (callback) => {
  return onAuthStateChanged(auth, callback);
};