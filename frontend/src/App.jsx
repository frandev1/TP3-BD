import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { LoginForm, UA, TH, Movimientos } from './pages/'
import 'bootstrap/dist/css/bootstrap.min.css';
import '@fortawesome/fontawesome-free/css/all.min.css';
import 'bootstrap/dist/js/bootstrap.bundle';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route 
          path="/" 
          element={<LoginForm/>} 
        />
        <Route 
          path="ua" 
          element={<UA />} 
        />
        <Route
          path='th'
          element={<TH />}
        />
        <Route
          path='movimientos'
          element={<Movimientos />}
        />
      </Routes>
    </BrowserRouter>
  );
}

export default App;


