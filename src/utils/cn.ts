import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

/**
 * Combina clases de Tailwind de forma segura
 */
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

/**
 * Formatea fechas para el locale de Argentina (DD/MM/YYYY)
 */
export function formatDate(date: Date | null | undefined, format: 'short' | 'long' | 'time' = 'short'): string {
  if (!date) return '-';

  const d = new Date(date);

  if (format === 'short') {
    return d.toLocaleDateString('es-AR', { day: '2-digit', month: '2-digit', year: 'numeric' });
  }

  if (format === 'long') {
    return d.toLocaleDateString('es-AR', {
      weekday: 'long',
      day: '2-digit',
      month: 'long',
      year: 'numeric'
    });
  }

  if (format === 'time') {
    return d.toLocaleTimeString('es-AR', { hour: '2-digit', minute: '2-digit' });
  }

  return d.toLocaleString('es-AR');
}

/**
 * Combina fecha y hora
 */
export function formatDateTime(date: Date | null | undefined): string {
  if (!date) return '-';
  const d = new Date(date);
  return `${formatDate(d, 'short')} ${formatDate(d, 'time')}`;
}

/**
 * Calcula la diferencia en días entre dos fechas (útil para KPIs de entrega)
 */
export function calcularDiferenciaDias(fechaInicio: Date | null, fechaFin: Date | null): number | null {
  if (!fechaInicio || !fechaFin) return null;
  const diff = fechaFin.getTime() - fechaInicio.getTime();
  return Math.floor(diff / (1000 * 60 * 60 * 24));
}