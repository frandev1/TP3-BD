import { BrowserRouter, Routes, Route } from 'react-router-dom';
import './App.css';
import { LoginForm, UA, TH } from './pages/'

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
      </Routes>
    </BrowserRouter>
  );
}

export default App;


