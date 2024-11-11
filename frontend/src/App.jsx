import { useState } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import './App.css';
import axios from 'axios';

function App() {
  const api = 'http://localhost:5000/api'
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [message, setMessage] = useState('');
  const [isLoggedIn, setIsLoggedIn] = useState(false);

  const handleLogin = async (event) => {
    event.preventDefault();
    await axios.post(
      `${api}/login`,
      {
        nombre: username,
        password
      },
      {
        headers:{
          'Content-Type': 'application/json'
        }
      }
    ).then(function(respuesta){
      console.log(respuesta)
      if (respuesta.data.authenticated) {
        setMessage('Inicio de sesión exitoso');
        setIsLoggedIn(true); // Cambia el estado de inicio de sesión
    } else {
        setMessage('Credenciales incorrectas');
    }
    })
    .catch(function(respuesta){
      console.error('Error en la solicitud de inicio de sesión:', error);
      setMessage('Error en el servidor');
    })
    // try {
    //     const response = await fetch('/api/auth/login', {
    //         method: 'POST',
    //         headers: {
    //             'Content-Type': 'application/json'
    //         },
    //         body: JSON.stringify({ nombre: username, password })
    //     });
        
    //     const data = await response.json();
        
    // } catch (error) {
    //     console.error('Error en la solicitud de inicio de sesión:', error);
    //     setMessage('Error en el servidor');
    // }
  };

  return (
    <BrowserRouter>
      <Routes>
        <Route 
          path="/" 
          element={
            isLoggedIn ? (
              <Navigate to="/bienvenida" replace />
            ) : (
              <LoginForm 
                username={username} 
                password={password} 
                setUsername={setUsername} 
                setPassword={setPassword} 
                handleLogin={handleLogin} 
                message={message} 
              />
            )
          } 
        />
        <Route 
          path="/bienvenida" 
          element={
            isLoggedIn ? (
              <Bienvenida />
            ) : (
              <Navigate to="/" replace />
            )
          } 
        />
      </Routes>
    </BrowserRouter>
  );
}

function LoginForm({ username, password, setUsername, setPassword, handleLogin, message }) {
  return (
    <div className="login">
      <h1>Iniciar Sesión</h1>
      <form onSubmit={handleLogin}>
        <label>Usuario:</label>
        <input
          type="text"
          value={username}
          onChange={(e) => setUsername(e.target.value)}
          required
        />
        <label>Contraseña:</label>
        <input
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          required
        />
        <button type="submit">Iniciar Sesión</button>
      </form>
      <p>{message}</p>
    </div>
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


