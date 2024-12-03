import { useEffect, useState } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import axios from "axios";
import PropTypes from 'prop-types';

function EstadosCuenta() {
    const location = useLocation();
    const tarjeta = location.state?.tarjeta;
    const api = 'http://localhost:5000/api';
    const navigate = useNavigate();
    const [estadoCuenta, setEstadoCuenta] = useState([]);
    const [error, setError] = useState(null);

    useEffect(() => {
        axios.get(
            `${api}/estadoCuenta/${tarjeta.codigoTarjeta}/${tarjeta.tipoCuenta}`
        )
        .then(function(respuesta) {
            setEstadoCuenta(respuesta.data);  // Guardar los datos de las tarjetas en el estado
            console.log(respuesta.data);
        })
        .catch(function(error) {
            console.error(error.respuesta?.data?.msg || "Error al obtener las tarjetas");
            setError("No se pudo obtener el estado de cuenta.")
        });
    }, [tarjeta]);

    const handleClick = (codigoTarjeta, TipoCuenta, FechaCorte) => {
        const estado = {
            tipoCuenta: TipoCuenta,
            codigoTarjeta: codigoTarjeta,
            fechaCorte: FechaCorte
          }
        return navigate('/movimientos', { state: { estado } })
    }

    return (
        <div>
            {error && <p>{error}</p>}
            {!error && (
                <div className='container-fluid'>
                <div className='row'>
                    <div className='col-12'>
                        <h2 className='text-bg-light p-3'>Estados de Cuenta {tarjeta?.codigoTarjeta}</h2>
                    </div>
                </div>
                <div className='row mt-3'>
                    <div className='col-12'>
                        <div className='table-responsive'>
                            <table className='table table-bordered'>
                                <thead>
                                    <tr>
                                        <th>Fecha Corte</th>
                                        <th>Pago Mínimo</th>
                                        <th>Pago Contratado</th>
                                        <th>Intereses Corrientes</th>
                                        <th>Intereses Moratorios</th>
                                        <th>Operaciones ATM</th>
                                        <th>Operaciones Ventanilla</th>
                                        <th>Movimientos</th>
                                    </tr>
                                </thead>
                                <tbody className='table-group-divider'>
                                    {estadoCuenta.map((estado, index) => (
                                        <tr key={index}>
                                            <td>{estado.FechaCorte}</td>
                                            <td>{estado.PagoMinimo}</td>
                                            <td>{estado.PagoContado}</td>
                                            <td>{estado.InteresesCorrientes}</td>
                                            <td>{estado.InteresesMoratorios}</td>
                                            <td>{estado.CantidadOperacionesATM}</td>
                                            <td>{estado.CantidadOperacionesVentanilla}</td>
                                            <td>
                                                <button className='btn btn-success'
                                                    onClick={() => handleClick(tarjeta.codigoTarjeta, tarjeta.tipoCuenta, estado.FechaCorte)}>
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
            )}
        </div>
    );
}


EstadosCuenta.propTypes = {
    tarjeta: PropTypes.shape({
        codigoTarjeta: PropTypes.string.isRequired,
        tipoTC: PropTypes.string.isRequired
    })
};

export default EstadosCuenta;