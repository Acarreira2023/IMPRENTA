import { useState } from 'react';
import { MOCK_MAQUINAS } from '../mock/mockData';
import { Maquina } from '../types';

export const useMaquinas = () => {
  const [maquinas, setMaquinas] = useState<Maquina[]>(MOCK_MAQUINAS);

  const getMaquinaById = (id: string) => maquinas.find(m => m.id === id);
  const getMaquinasPorTipo = (tipo: Maquina['tipo']) => maquinas.filter(m => m.tipo === tipo);

  return { maquinas, getMaquinaById, getMaquinasPorTipo };
};