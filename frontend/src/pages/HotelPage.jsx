import React from "react";
import HotelsRow from "../components/HotelRow";
import HotelCarousel from "../components/HotelCarousel";
import TopNavbar from "../components/HotelPageNavbar";
import backimg from "../assets/back.png";
import Footer from "../components/HotelPageFooter"

const HotelPage = () => {
  return (
    <div style={styles.page}>
      {/* Background image */}
      <div style={styles.background}></div>

      {/* Soft overlay */}
      <div style={styles.overlay}></div>

      {/* Main content */}
      <div style={styles.content}>
        <TopNavbar userName="John" />

        <div style={styles.carousel} >
          <HotelCarousel />
        </div>

        <div style={styles.section}>
          <HotelsRow />
        </div>
         <Footer />
      </div>
    </div>
  );
};

const styles = {
  page: {
    position: "relative",
    minHeight: "100vh",
    overflowX: "hidden",
  },

  background: {
    position: "fixed",
    inset: 0,
    backgroundImage: `url(${backimg})`,
    backgroundSize: "cover",
    backgroundPosition: "center",
    backgroundRepeat: "no-repeat",
    filter: "blur(2px)",          // ✅ very subtle blur
    transform: "scale(1.05)",     // ✅ avoids blur edge artifacts
    zIndex: -2,
  },

  overlay: {
    position: "fixed",
    inset: 0,
    backgroundColor: "rgba(255,255,255,0.92)", // ✅ stronger overlay
    zIndex: -1,
  },

  content: {
    position: "relative",
    zIndex: 1,
  },

  section: {
    backgroundColor: "#ffffff",
    borderRadius: "16px",
    padding: "24px",
    margin: "24px auto",
    maxWidth: "1200px",
    boxShadow: "0 4px 20px rgba(0,0,0,0.06)",
  },
  carousel: {

    backgroundColor: "#efe9e9",
    borderRadius: "0px",
    padding: "24px",
    margin: "24px auto",
    maxWidth: "1500px",
    //boxShadow: "0 4px 20px rgba(0,0,0,0.06)",
  },

};

export default HotelPage;
