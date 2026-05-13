import { useState } from 'react';
import { MOCK_ALERTAS } from '../mock/mockData';
import { Alerta } from '../types';

export const useAlertas = () => {
  const [alertas, setAlertas] = useState<Alerta[]>(MOCK_ALERTAS);

  const alertasNoLeidas = alertas.filter(a => !a.leida);
  const marcarComoLeida = (id: string) => {
    setAlertas(prev => prev.map(a => a.id === id ? { ...a, leida: true } : a));
  };

  return { alertas, alertasNoLeidas, marcarComoLeida };
};