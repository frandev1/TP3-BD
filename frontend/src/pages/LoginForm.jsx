import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios'
import './LoginForm.css'
import { show_alerta } from '../function';

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
          var tipo, msj;
          msj = respuesta.data.msg
          tipo = 'success';
          show_alerta(msj, tipo);
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
    } 
    })
    .catch(function(error){
      var msj = error.response.data.msg;
      if(error.response.status === 400){
          show_alerta(msj,'warning');
      }
      else if(error.response.status === 401){
          show_alerta(msj,'warning');
      }
      else{
          show_alerta(msj,'error');
          console.log(error);
      }
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