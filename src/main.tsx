import React, { Suspense } from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';

// Importación de App
import App from './App';

// Estilos globales (Tailwind)
import './index.css';

/**
 * 1. Verificación del elemento Raíz
 * Es una buena práctica asegurarse de que el DOM está listo antes de intentar montar React.
 */
const rootElement = document.getElementById('root');

if (!rootElement) {
  throw new Error(
    "Error Fatal: No se encontró el elemento con id 'root'. " +
    "Asegurate de que index.html tenga un <div id='root'></div>"
  );
}

const root = ReactDOM.createRoot(rootElement);

/**
 * 2. Estructura de Proveedores (Context Providers)
 * Aquí se centraliza la configuración global.
 */
root.render(
  <React.StrictMode>
    {/* Suspense: Muestra un loader si algún componente hijo
        se está cargando de forma asíncrona.
    */}
    <Suspense fallback={
      <div className="h-screen w-screen flex items-center justify-center bg-gray-50">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-600"></div>
      </div>
    }>
      <BrowserRouter>
        {/* Aquí se pueden envolver con AuthProvider o ThemeProvider
            cuando se necesite en el futuro.
        */}
        <App />
      </BrowserRouter>
    </Suspense>
  </React.StrictMode>
);