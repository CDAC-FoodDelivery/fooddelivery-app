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
import AdminDashboard from "./pages/AdminDashboardPage";
import RiderDashboard from "./pages/RiderDashboard";
import CartPage from "./pages/CartPage";

import { AuthProvider } from "./context/AuthContext";
import { WishlistProvider } from "./context/WishlistContext";
import { CartProvider } from "./context/CartContext";
import WishlistPage from "./pages/WishlistPage";
import TrendingPage from "./pages/TrendingPage";
import SearchPage from "./pages/SearchPage";
import ProtectedRoute from "./components/ProtectedRoute";
import RiderSignUp from "./pages/RiderSignUp";
import AdminRiderLogin from "./pages/AdminRiderLogin";

function App() {
  return (
    <AuthProvider>
      <WishlistProvider>
        <CartProvider>
          <BrowserRouter>
            <ToastContainer position="top-right" autoClose={3000} />
            <Routes>
              <Route path="/" element={<SignIn />} />
              <Route path="/admin-rider-login" element={<AdminRiderLogin />} />
              <Route path="/signup" element={<SignUp />} />
              <Route path="/rider-signup" element={<RiderSignUp />} />

              <Route path="/home" element={<ProtectedRoute><MainLayout /></ProtectedRoute>}>
                <Route path="hotel/:hotelId/menu" element={<ProductsPage />} />
                <Route path="cart" element={<CartPage />} />
                <Route path="payment" element={<Payment />} />
                <Route path="wishlist" element={<WishlistPage />} />
                <Route path="trending" element={<TrendingPage />} />
                <Route path="search" element={<SearchPage />} />
              </Route>

              <Route path="/adminDashboard" element={<ProtectedRoute><AdminDashboard /></ProtectedRoute>} />
              <Route path="/riderDashboard" element={<ProtectedRoute><RiderDashboard /></ProtectedRoute>} />
            </Routes>
          </BrowserRouter>
        </CartProvider>
      </WishlistProvider>
    </AuthProvider>
  );
}

export default App;
