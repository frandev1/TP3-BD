import { useEffect, useState } from "react";
import { useLocation } from "react-router-dom";
import axios from "axios";
import PropTypes from 'prop-types';

function Movimientos() {
  const api = "http://localhost:5000/api";
  const location = useLocation();
  // const estadoCuenta = location.state?.estadoCuenta;
  const estado = location.state?.estado;
  const [movimientos, setMovimientos] = useState([]);

  useEffect(() => {
    axios
      .get(
        // `${api}/${estadoCuenta?.estadoCuenta}`
        `${api}/movimientos/${estado.codigoTarjeta}/${estado.tipoCuenta}/${estado.fechaCorte}`
      )
      .then(function (respuesta) {
        setMovimientos(respuesta.data); // Guardar los datos de las tarjetas en el estado
        console.log(respuesta.data);
      })
      .catch(function (error) {
        console.error(
          error.response?.data?.msg || "Error al obtener los movimientos"
        );
      });
  }, [estado]);

  return (
    <div>
      <div className="container-fluid">
        <div className="row">
          <div className="col-12">
            <h2 className="text-bg-light p-3">Movimientos</h2>
          </div>
        </div>
        <div className="row mt-3">
          <div className="col-12">
            <div className="table-responsive">
              <table className="table table-bordered">
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
                <tbody className="table-group-divider">
                  {movimientos?.map((mov, index) => (
                    <tr key={index}>
                      <td>{mov.FechaMovimiento}</td>
                      <td>{mov.Nombre}</td>
                      <td>{mov.Descripcion}</td>
                      <td>{mov.Referencia}</td>
                      <td>{mov.Monto}</td>
                      <td>{mov.NuevoSaldo}</td>
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

Movimientos.propTypes = {
    tarjeta: PropTypes.shape({
        tipoCuenta: PropTypes.string.isRequired,
        codigoTarjeta: PropTypes.string.isRequired,
        fechaCorte: PropTypes.string.isRequired
    })
};

export default Movimientos;
// const [movimientos, setMovimientos] = useState([]); // Estado para almacenar los movimientos
// const [mostrarModal, setMostrarModal] = useState(false); // Estado para mostrar el modal

// Función para obtener los movimientos de una tarjeta
// const obtenerMovimientos = async (codigoTarjeta) => {
//     try {
//         const response = await axios.get(`${api}/movimientos/${codigoTarjeta}`);
//         setMovimientos(response.data); // Guardar los movimientos en el estado
//         setMostrarModal(true); // Mostrar el modal

//     } catch (error) {
//         console.error("Error al obtener los movimientos:", error);
//     }
// };

// {/* Modal para mostrar los movimientos */}
// {mostrarModal && (
//     <div className="modal show d-block" tabIndex="-1">
//         <div className="modal-dialog modal-lg">
//             <div className="modal-content">
//                 <div className="modal-header">
//                     <h5 className="modal-title">Movimientos</h5>
//                     <button
//                         type="button"
//                         className="btn-close"
//                         onClick={() => setMostrarModal(false)}
//                     ></button>
//                 </div>
//                 <div className="modal-body">
//                     <table className="table table-striped">
//                         <thead>
//                             <tr>
//                                 <th>Fecha de Operación</th>
//                                 <th>Nombre de Tipo de Movimiento</th>
//                                 <th>Descripción</th>
//                                 <th>Referencia</th>
//                                 <th>Monto</th>
//                                 <th>Nuevo Saldo</th>
//                             </tr>
//                         </thead>
//                         <tbody>
//                             {movimientos.map((mov, idx) => (
//                                 <tr key={idx}>
//                                     <td>{mov['Fecha de Operación']}</td>
//                                     <td>{mov['Nombre de Tipo de Movimiento']}</td>
//                                     <td>{mov.Descripción}</td>
//                                     <td>{mov.Referencia}</td>
//                                     <td>{mov.Monto}</td>
//                                     <td>{mov['Nuevo Saldo']}</td>
//                                 </tr>
//                             ))}
//                         </tbody>
//                     </table>
//                 </div>
//             </div>
//         </div>
//     </div>
// )}
