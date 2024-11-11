import { useState } from 'react';
import './App.css';

function App() {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [isLoggedIn, setIsLoggedIn] = useState(false);

  // Simula la autenticación de usuario
  const handleLogin = (event) => {
    event.preventDefault();
    if (username === 'usuario' && password === 'contraseña') { // Cambia 'usuario' y 'contraseña' por tus credenciales deseadas
      setIsLoggedIn(true);
    } else {
      alert('Credenciales incorrectas');
    }
  };


   // Funciones de acción (consulta, inserción, actualización, eliminación)
   const handleConsultar = () => {
    alert("Acción de consulta realizada");
  };

  const handleInsertar = () => {
    alert("Acción de inserción realizada");
  };

  const handleActualizar = () => {
    alert("Acción de actualización realizada");
  };

  const handleEliminar = () => {
    alert("Acción de eliminación realizada");
  };

  return (
    <>
      {!isLoggedIn ? (
        <div className="login">
          <h1>TERCERA TAREA PROGRAMADA</h1>
          <h1>Iniciar Sesión</h1>
          <form onSubmit={handleLogin}>
            <div>
              <h3>Sistema de Tarjeta de Crédito</h3>
              <label>Usuario:</label>
              <input
                type="text"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                required
              />
            </div>
            <div>
              <label>Contraseña:</label>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>
            <button type="submit">Iniciar Sesión</button>
          </form>
          <h2>Maikel Cordero Franco Rojas</h2>
        </div>
        
      ) : (
        <div>
          <h1>Bienvenido al Panel de Control</h1>
          <div className="actions">
            <button onClick={handleConsultar}>Consultar</button>
            <button onClick={handleInsertar}>Insertar</button>
            <button onClick={handleActualizar}>Actualizar</button>
            <button onClick={handleEliminar}>Eliminar</button>
          </div>
        </div>
      )}
    </>
  );
}

export default App;


