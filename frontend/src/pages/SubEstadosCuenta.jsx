import { useEffect, useState } from "react";
import { useLocation } from "react-router-dom";
import axios from "axios";
import PropTypes from 'prop-types';


function SubEstadoCuenta() {
    const [estadoCuenta, setEstadoCuenta] = useState([]);
    const [error, setError] = useState(null);

    const fetchEstadoCuenta = async () => {
        // AQUI FALTA CÓDIGO PARA BUSCAR EL CODIGO DE LA TARJETA    

        try {
            const response = await axios.get(
                `http://localhost:3000/api/estadoCuenta/${codigoTF}/${tipoTC}`
            );
            setEstadoCuenta(response.data);
        } catch (err) {
            console.error("Error al obtener estado de cuenta:", err);
            setError("No se pudo obtener el estado de cuenta.");
        }
    };

    useEffect(() => {
        fetchEstadoCuenta();
    }, []);

    return (
        <div>
            <h1>Estado de Cuenta</h1>
            {error && <p>{error}</p>}
            {!error && (
                <table>
                    <thead>
                        <tr>
                            <th>Fecha Corte</th>
                            <th>Pago Mínimo</th>
                            <th>Pago Contratado</th>
                            <th>Intereses Corrientes</th>
                            <th>Intereses Moratorios</th>
                            <th>Operaciones ATM</th>
                            <th>Operaciones Ventanilla</th>
                        </tr>
                    </thead>
                    <tbody>
                        {estadoCuenta.map((estado, index) => (
                            <tr key={index}>
                                <td>{estado.FechaCorte}</td>
                                <td>{estado.PagoMinimo}</td>
                                <td>{estado.PagoContratado}</td>
                                <td>{estado.InteresesCorrientes}</td>
                                <td>{estado.InteresesMoratorios}</td>
                                <td>{estado.CantidadOperacionesATM}</td>
                                <td>{estado.CantidadOperacionesVentanilla}</td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            )}
        </div>
    );
}

export default SubEstadoCuenta;