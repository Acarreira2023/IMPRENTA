import { 
  signInWithEmailAndPassword, 
  signOut, 
  onAuthStateChanged, 
  User as FirebaseUser 
} from 'firebase/auth';
import { auth } from './firebase';
import { getUsuario } from './firestore'; // Lo crearemos en el siguiente paso

export const login = async (email: string, password: string) => {
  try {
    const userCredential = await signInWithEmailAndPassword(auth, email, password);
    const usuario = await getUsuario(userCredential.user.uid);
    
    return { 
      success: true, 
      user: usuario, 
      mustChange: usuario?.mustChange 
    };
  } catch (error: any) {
    return { success: false, error: 'Credenciales inválidas' };
  }
};

export const logout = () => signOut(auth);

export const onAuthChange = (callback: (user: FirebaseUser | null) => void) => {
  return onAuthStateChanged(auth, callback);
};