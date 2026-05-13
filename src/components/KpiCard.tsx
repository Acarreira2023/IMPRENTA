import React from 'react';
import { LucideIcon } from 'lucide-react';
import { cn } from '../utils/cn';

interface KpiCardProps {
  title: string;
  value: string | number;
  icon: LucideIcon;
  color?: 'blue' | 'green' | 'orange' | 'red' | 'purple';
}

const KpiCard: React.FC<KpiCardProps> = ({
  title,
  value,
  icon: Icon,
  color = 'blue',
}) => {
  // Mapeo de colores para el icono y su fondo
  const colorStyles = {
    blue: "bg-blue-50 text-blue-600 border-blue-100",
    green: "bg-green-50 text-green-600 border-green-100",
    orange: "bg-orange-50 text-orange-600 border-orange-100",
    red: "bg-red-50 text-red-600 border-red-100",
    purple: "bg-purple-50 text-purple-600 border-purple-100",
  };

  return (
    <div className="bg-white p-5 rounded-2xl border border-gray-200 shadow-sm flex items-center justify-between transition-all hover:shadow-md">
      <div className="space-y-1">
        <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider">
          {title}
        </p>
        <h3 className="text-2xl font-black text-gray-900 tracking-tight">
          {value}
        </h3>
      </div>
      
      <div className={cn(
        "p-3 rounded-xl border flex items-center justify-center",
        colorStyles[color]
      )}>
        <Icon className="w-6 h-6" />
      </div>
    </div>
  );
};

export default KpiCard;