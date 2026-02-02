import { Outlet, useLocation } from "react-router-dom";
import Navbar from "../components/Navbar";
import LeftSidebar from "../components/LeftSidebar";
import HotelCarousel from "../components/HotelCarousel";
import HotelsRow from "../components/HotelRow";
import Footer from "../components/HotelPageFooter";

const MainLayout = () => {
  const location = useLocation();
  const isHomePage = location.pathname === "/home";
  const isPaymentPage = location.pathname === "/payment";
  const isHotelMenuPage = location.pathname.includes("/hotel/");

  return (
    <div className="min-vh-100 d-flex flex-column">
      {!isPaymentPage && <Navbar />}

      <div className="d-flex flex-grow-1" style={{ minHeight: "100vh", paddingTop: !isPaymentPage ? 78 : 0 }}>
        {!isPaymentPage && <LeftSidebar />}

        <main className="flex-grow-1" style={{ paddingLeft: !isPaymentPage ? "70px" : 0 }}>
          {isHomePage && (
            <>
              <div className="w-100"><HotelCarousel /></div>
              <HotelsRow />
            </>
          )}

          <div className="flex-grow-1">
            <Outlet />
          </div>
        </main>
      </div>

      {!isHotelMenuPage && <Footer />}
    </div>
  );
};

export default MainLayout;
