import { BrowserRouter, Routes, Route } from 'react-router-dom';
import './App.css';
import LoginForm from './pages/LoginForm';

function App() {

  

  return (
    <BrowserRouter>
      <Routes>
        <Route 
          path="/" 
          element={<LoginForm/>} 
        />
        <Route 
          path="/bienvenida" 
          element={<Bienvenida />} 
        />
      </Routes>
    </BrowserRouter>
  );
}

function Bienvenida() {
  return (
    <div>
      <h1>Bienvenido al Sistema</h1>
      <p>Has iniciado sesión exitosamente.</p>
    </div>
  );
}

export default App;


