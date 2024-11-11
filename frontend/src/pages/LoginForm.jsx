import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios'

function LoginForm() {  
  const api = 'http://localhost:5000/api'
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [message, setMessage] = useState('');
  const navigate = useNavigate();

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
        if (respuesta.data.tipoUsuario == 'UA'){
          return navigate('/ua')
        } else {
          return navigate('th')
        }
    } else {
        setMessage('Credenciales incorrectas');
    }
    })
    .catch(function(respuesta){
      console.error('Error en la solicitud de inicio de sesión:', respuesta);
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
        <div className="login">
            <h1>Iniciar Sesión</h1>
            <form onSubmit={handleLogin}>
            <label>Usuario:</label>
            <input
                type="text"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
            />
            <label>Contraseña:</label>
            <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
            />
            <button type="submit">Iniciar Sesión</button>
            </form>
            <p>{message}</p>
        </div>
    );
  }

export default LoginForm;