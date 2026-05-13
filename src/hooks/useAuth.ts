import { useState } from 'react';
import { MOCK_SESSION_DEMO } from '../mock/mockData';
import { Usuario } from '../types';

export const useAuth = () => {
  // Inicializamos con el usuario demo para que la UI no rompa
  const [user, setUser] = useState<Usuario | null>(MOCK_SESSION_DEMO);

  const isAdmin = user?.rol === 'admin';
  const isOperario = user?.rol === 'operario';

  return { user, isAdmin, isOperario, setUser };
};