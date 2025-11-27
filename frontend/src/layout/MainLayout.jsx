import LeftSidebar from "../components/LeftSidebar";
import Navbar from "../components/Navbar";
import RightSidebar from "../components/RightSidebar";
import ProductsPage from './../pages/ProductsPage';

const MainLayout = () => {
  return (
    <div className="d-flex flex-row min-vh-100">
      <LeftSidebar />
      <div className="flex-grow-1 d-flex flex-column" style={{ background: "#faf9f6" }}>
        <Navbar />
        <ProductsPage />
      </div>
      <RightSidebar />
    </div>
  );
};

export default MainLayout;
