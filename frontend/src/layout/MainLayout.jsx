import { Outlet, useLocation } from "react-router-dom";
import Navbar from "../components/Navbar";
import LeftSidebar from "../components/LeftSidebar";
import RightSidebar from "../components/RightSidebar";

const MainLayout = () => {
  const location = useLocation();

  // Pages where layout should be hidden
  const isPaymentPage = location.pathname === "/payment";

  return (
    <div className="min-vh-100">

      {/* Navbar only for non-payment pages */}
      {!isPaymentPage && <Navbar />}

      <div
        className={`d-flex ${!isPaymentPage ? "flex-row" : ""}`}
        style={{
          minHeight: "100vh",
        }}
      >
        {/* Left Sidebar */}
        {!isPaymentPage && <LeftSidebar />}

        {/* Main Content */}
        <main
          className="flex-grow-1 p-3"
          style={{ background: "#faf9f6" }}
        >
          <Outlet />
        </main>

        {/* Right Sidebar */}
        {!isPaymentPage && <RightSidebar />}
      </div>
    </div>
  );
};

export default MainLayout;
