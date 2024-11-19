/* eslint-disable react-refresh/only-export-components */
import { useEffect, useState } from 'react';
import axios from 'axios';
import { useLocation, useNavigate } from 'react-router-dom';
import PropTypes from 'prop-types';

function UA() {
    const location = useLocation();
    const user = location.state?.user;
    const api = 'http://localhost:5000/api';
    const [tarjetas, setTarjetas] = useState([]);
    const navigate = useNavigate();

    useEffect(() => {
        // Llamada a la API para obtener todas las tarjetas
        axios.post(
            `${api}/tarjetasUA`,
            {
                nombreUsuario: user?.nombre 
            },
            {
                headers: {
                    'Content-Type': 'application/json'
                }
            }
        )
        .then(function(respuesta) {
            setTarjetas(respuesta.data);  // Guardar los datos de las tarjetas en el estado
            console.log(respuesta.data);
        })
        .catch(function(error) {
            console.error(error.response?.data?.msg || "Error al obtener las tarjetas");
        });
    }, [user?.nombre]);

    const handleMovimientos = (codigoTarjeta) => {
        const tarjeta = {
            codigoTarjeta: codigoTarjeta
          }
        return navigate('/movimientos', { state: { tarjeta } })
    } 

    return (
        <div>
            <div className='container-fluid'>
                <div className='row'>
                    <div className='col-12'>
                        <h2 className='text-bg-light p-3'>Bienvenido, {user?.nombre}</h2>
                    </div>
                </div>
                <div className='row mt-3'>
                    <div className='col-12'>
                        <div className='table-responsive'>
                            <table className='table table-bordered'>
                                <thead>
                                    <tr>
                                        <th>Tipo de Tarjeta</th>
                                        <th>Código de Tarjeta</th>
                                        <th>Código de Tarjeta física</th>
                                        <th>Nombre del Usuario TH</th>
                                        <th>Movimientos</th>
                                        <th>Estado de Cuenta</th>
                                    </tr>
                                </thead>
                                <tbody className='table-group-divider'>
                                    {tarjetas?.map((tarjeta, index) => (
                                        <tr key={index}>
                                            <td>{tarjeta.TipoTarjeta}</td>
                                            <td>{tarjeta.CodigoTarjeta}</td>
                                            <td>{tarjeta.CodigoTarjetaFisica}</td>
                                            <td>{tarjeta.NombreTarjetahabiente}</td>
                                            <td>
                                                <button
                                                    onClick={() => handleMovimientos(tarjeta.CodigoTarjeta)}
                                                    className='btn btn-success'
                                                >
                                                    <i className='fa-solid fa-clipboard'></i>
                                                </button>
                                                
                                            </td>
                                            <td>
                                                <button className='btn btn-warning'>
                                                    <i className='fa-solid fa-file-invoice-dollar'></i>
                                                </button>
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}

UA.propTypes = {
    user: PropTypes.shape({
        nombre: PropTypes.string.isRequired,
    })
};

export default UA;

