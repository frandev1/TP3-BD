/* eslint-disable react-refresh/only-export-components */
import { useEffect, useState } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import PropTypes from 'prop-types';
import axios from 'axios';

function TH() {
    const location = useLocation();
    const user = location.state?.user;
    const api = 'http://localhost:5000/api';
    const navigate = useNavigate();
    const [tarjetas, setTarjetas] = useState([]);

    useEffect(() => {
        axios.post(
            `${api}/th`,
            {
                usuarioTH: user?.userName
            },
            {
                headers: {
                    'Content-Type': 'application/json'
                }
            }
        )
        .then(function(respuesta) {
            setTarjetas(respuesta.data.recordset);
            console.log(respuesta.data);
        })
        .catch(function(error) {
            console.error(error.response?.data?.msg || "Error al obtener las tarjetas");
        });
    }, [user?.userName, user?.nombre]);

    const handleClick = (TipoCuenta, codigoTarjeta) => {
        const tarjeta = {
            tipoCuenta: TipoCuenta,
            codigoTarjeta: codigoTarjeta
          }
        console.log(TipoCuenta)
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
                        <h2 className='text-bg-light p-3'>Bienvenid@, {user?.nombre}</h2>
                    </div>
                </div>
                <div className='row mt-3'>
                    <div className='col-12'>
                        <div className='table-responsive'>
                            <table className='table table-bordered'>
                                <thead>
                                    <tr>
                                        <th>NUMERO</th>
                                        <th>ESTADO</th>
                                        <th>TIPO</th>
                                        <th>VENCIMIENTO</th>
                                        <th>ESTADO DE CUENTA</th>
                                    </tr>
                                </thead>
                                <tbody className='table-group-divider'>
                                    {tarjetas?.map((tarjeta) => (
                                        <tr key={tarjeta.id}>
                                            <td>{tarjeta.NumeroTarjeta}</td>
                                            <td>{tarjeta.EstadoCuenta}</td>
                                            <td>{tarjeta.TipoCuenta}</td>
                                            <td>{tarjeta.FechaVencimiento}</td>
                                            <td>
                                                <button onClick={()=> handleClick(tarjeta.TipoCuenta, tarjeta.NumeroTarjeta)}
                                                    className='btn btn-success' data-bs-toggle='modal' data-bs-target='#modal'>
                                                        <i className='fa-solid fa-clipboard'></i>
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

TH.propTypes = {
    user: PropTypes.shape({
        userName: PropTypes.string.isRequired,
        nombre: PropTypes.string.isRequired
    })
};

export default TH;
