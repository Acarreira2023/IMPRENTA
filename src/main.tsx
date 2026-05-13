import React, { Suspense } from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';

// Importación de App
import App from './App';

// Importación de  Provider
import { AuthProvider } from './context/AuthContext';

// Estilos globales (Tailwind)
import './index.css';

const rootElement = document.getElementById('root');

if (!rootElement) {
  throw new Error(
    "Error Fatal: No se encontró el elemento con id 'root'. " +
    "Asegurar de que index.html tenga un <div id='root'></div>"
  );
}

const root = ReactDOM.createRoot(rootElement);

root.render(
  <React.StrictMode>
    <Suspense fallback={
      <div className="h-screen w-screen flex items-center justify-center bg-gray-50">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-600"></div>
      </div>
    }>
      {/* AuthProvider ahora envuelve toda la lógica de la aplicación */}
      <AuthProvider>
        <BrowserRouter>
          <App />
        </BrowserRouter>
      </AuthProvider>
    </Suspense>
  </React.StrictMode>
);