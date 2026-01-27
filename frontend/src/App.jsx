import "bootstrap/dist/css/bootstrap.min.css";
import "bootstrap/dist/js/bootstrap.bundle.min.js";
import "bootstrap-icons/font/bootstrap-icons.css";
import "react-toastify/dist/ReactToastify.css";
import { ToastContainer } from "react-toastify";

import { BrowserRouter, Routes, Route } from "react-router-dom";

import MainLayout from "./layout/MainLayout";
import SignIn from "./pages/SignIn";
import SignUp from "./pages/SignUp";
import ProductsPage from "./pages/ProductsPage";
import Payment from "./pages/Payment";
import AdminDashboard from "./pages/AdminDashboard";
import RiderDashboard from "./pages/RiderDashboard";
import CartPage from "./pages/CartPage";

function App() {
  return (
    <BrowserRouter>
      <ToastContainer position="top-right" autoClose={3000} />
      <Routes>
        <Route path="/" element={<SignIn />} />
        <Route path="/signup" element={<SignUp />} />

        <Route path="/home" element={<MainLayout />}>
          <Route path="hotel/:hotelId/menu" element={<ProductsPage />} />
          <Route path="cart" element={<CartPage />} />
          <Route path="payment" element={<Payment />} />
        </Route>

        <Route path="/adminDashboard" element={<AdminDashboard />} />
        <Route path="/riderDashboard" element={<RiderDashboard />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
