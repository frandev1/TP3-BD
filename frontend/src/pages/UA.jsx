/* eslint-disable react-refresh/only-export-components */
import { useEffect, useState } from 'react';
import axios from 'axios';
import { useLocation } from 'react-router-dom';
import PropTypes from 'prop-types';

function UA() {
    const location = useLocation();
    const user = location.state?.user;
    const api = 'http://localhost:5000/api';
    const [tarjetas, setTarjetas] = useState([]);
    const [movimientos, setMovimientos] = useState([]); // Estado para almacenar los movimientos
    const [mostrarModal, setMostrarModal] = useState(false); // Estado para mostrar el modal

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

    // Función para obtener los movimientos de una tarjeta
    const obtenerMovimientos = async (codigoTarjeta) => {
        try {
            const response = await axios.get(`${api}/movimientos/${codigoTarjeta}`);
            setMovimientos(response.data); // Guardar los movimientos en el estado
            setMostrarModal(true); // Mostrar el modal
            
        } catch (error) {
            console.error("Error al obtener los movimientos:", error);
        }
    };

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
                                                    className='btn btn-success'
                                                    onClick={() => obtenerMovimientos(tarjeta.CodigoTarjeta)}
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

            {/* Modal para mostrar los movimientos */}
            {mostrarModal && (
                <div className="modal show d-block" tabIndex="-1">
                    <div className="modal-dialog modal-lg">
                        <div className="modal-content">
                            <div className="modal-header">
                                <h5 className="modal-title">Movimientos</h5>
                                <button
                                    type="button"
                                    className="btn-close"
                                    onClick={() => setMostrarModal(false)}
                                ></button>
                            </div>
                            <div className="modal-body">
                                <table className="table table-striped">
                                    <thead>
                                        <tr>
                                            <th>Fecha de Operación</th>
                                            <th>Nombre de Tipo de Movimiento</th>
                                            <th>Descripción</th>
                                            <th>Referencia</th>
                                            <th>Monto</th>
                                            <th>Nuevo Saldo</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {movimientos.map((mov, idx) => (
                                            <tr key={idx}>
                                                <td>{mov['Fecha de Operación']}</td>
                                                <td>{mov['Nombre de Tipo de Movimiento']}</td>
                                                <td>{mov.Descripción}</td>
                                                <td>{mov.Referencia}</td>
                                                <td>{mov.Monto}</td>
                                                <td>{mov['Nuevo Saldo']}</td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}

UA.propTypes = {
    user: PropTypes.shape({
        nombre: PropTypes.string.isRequired,
    })
};

export default UA;

