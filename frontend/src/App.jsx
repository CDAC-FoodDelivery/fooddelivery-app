import "bootstrap/dist/css/bootstrap.min.css";
import "bootstrap/dist/js/bootstrap.bundle.min.js";
import "bootstrap-icons/font/bootstrap-icons.css";

import { BrowserRouter, Routes, Route } from "react-router-dom";

import MainLayout from "./layout/MainLayout";
import SignIn from "./pages/SignIn";
import SignUp from "./pages/SignUp";
import ProductsPage from "./pages/ProductsPage";
import Payment from "./pages/Payment";
import HotelsPage from "./pages/HotelPage";
import AdminDashboard from "./pages/adminDashboard"
import RiderDashboard from "./pages/RiderDashboard"

function App() {
  return (
    <BrowserRouter>
      <Routes>

        {/* Public routes (NO layout) */}
        <Route path="/" element={<SignIn />} />
        <Route path="/signup" element={<SignUp />} />
        <Route path="/home" element={<HotelsPage />} />          { /*Hotel page is home page hence /home*/}
        {/* Layout routes */}
        <Route element={<MainLayout />}>
            <Route path="/product/:hotelId" element={<ProductsPage />} />

         {/* <Route path="/product" element={<ProductsPage />} />*/}
          <Route path="/payment" element={<Payment />} />
        </Route>
        <Route path="/adminDashboard" element={<AdminDashboard />} />
        <Route path="/riderDashboard" element={<RiderDashboard />} />

      </Routes>
    </BrowserRouter>
  );
}

export default App;
