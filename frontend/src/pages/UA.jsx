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

    const handleClick = (TipoCuenta, codigoTarjeta,) => {
        const tarjeta = {
            tipoCuenta: TipoCuenta,
            codigoTarjeta: codigoTarjeta
          }
        if (TipoCuenta == 'TCM') {
            return navigate('/estadoscuenta', { state: { tarjeta } })
        }
        if (TipoCuenta =='TCA')
            return navigate('/subestadoscuenta', { state: { tarjeta } })
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
                                        <th>Tarjeta Habiente</th>
                                        <th>Fecha Vencimiento</th>
                                        <th>Estado Tarjeta</th>
                                        <th>Estado de Cuenta</th>
                                    </tr>
                                </thead>
                                <tbody className='table-group-divider'>
                                    {tarjetas?.map((tarjeta, index) => (
                                        <tr key={index}>
                                            <td>{tarjeta.TipoCuenta}</td>
                                            <td>{tarjeta.NumeroTarjeta}</td>
                                            <td>{tarjeta.NombreTH}</td>
                                            <td>{tarjeta.FechaVencimiento}</td>
                                            <td>{tarjeta.EstadoCuenta}</td>
                                            <td>
                                                <button className='btn btn-success'
                                                    onClick={(e) => handleClick(e.target.TipoCuenta, e.target.NumeroTarjeta)}>
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

