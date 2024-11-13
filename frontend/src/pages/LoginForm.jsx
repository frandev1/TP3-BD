import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios'
import './LoginForm.css'

function LoginForm() {  
  const api = 'http://localhost:5000/api'
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
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
        if (respuesta.data.tipoUsuario == 'UA'){
          const user = {
            nombre: username
          }
          return navigate('ua', { state: { user } })
        } else {
          const user = {
            nombre: username
          }
          return navigate('th', { state: { user } })
        }
    } else {
        // setMessage('Credenciales incorrectas');
    }
    })
    .catch(function(respuesta){
      console.error('Error en la solicitud de inicio de sesión:', respuesta);
      // setMessage('Error en el servidor');
    })
  };
    return (
        <div className="login">
            <form onSubmit={handleLogin}>
            <h1>Iniciar Sesión</h1>
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
        </div>
    );
  }

export default LoginForm;