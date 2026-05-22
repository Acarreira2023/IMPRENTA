import React, { Suspense } from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';

// Estilos globales (Tailwind)
import './index.css';

// Importación de App con extensión explícita para evitar fallas en bundlers
import App from './App.jsx';



const rootElement = document.getElementById('root');

if (!rootElement) {
  throw new Error(
    "Error Fatal: No se encontró el elemento con id 'root'. " +
    "Asegurarse de que index.html tenga un <div id='root'></div>"
  );
}

const root = ReactDOM.createRoot(rootElement);

root.render(
  <React.StrictMode>
    <Suspense fallback={
      <div className="h-screen w-screen flex items-center justify-center bg-slate-50">
        <div className="animate-spin rounded-full h-10 w-10 border-t-2 border-b-2 border-orange-500"></div>
      </div>
    }>
      <BrowserRouter>
        {/* AuthProvider se ejecuta internamente dentro de <App /> para evitar herencias duplicadas */}
        <App />
      </BrowserRouter>
    </Suspense>
  </React.StrictMode>
);