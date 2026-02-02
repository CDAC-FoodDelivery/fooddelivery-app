import React, { useState, useEffect } from "react";
import TypingText from "./TypingText";

const slides = [
  "https://images.pexels.com/photos/315755/pexels-photo-315755.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
  "https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
  "https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
  "https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
];

const HotelCarousel = () => {
  const [index, setIndex] = useState(0);

  useEffect(() => {
    const timer = setInterval(() => {
      setIndex((prev) => (prev + 1) % slides.length);
    }, 3000);
    return () => clearInterval(timer);
  }, []);

  return (
    <div
      style={{
        width: "101%",
        height: "551px",        // ✅ Standard app hero height
        overflow: "hidden",
        marginBottom: "25px",   // ✅ Standard spacing
        position: "relative",
      }}
    >
      <img
        src={slides[index]}
        alt="Hotel slide"
        style={{
          width: "100%",
          height: "100%",        // ✅ Full container height
          objectFit: "cover",
          transition: "opacity 0.8s ease",
          opacity: 1,
        }}
      />

      {/* Overlay for typing text */}
      <div
        style={{
          position: "absolute",
          top: "15%",
          left: "30%",
          transform: "translate(-50%, -50%)",
          textAlign: "center",
          color: "#ffffff",
          backgroundColor: "rgba(0, 0, 0, 0)",
          padding: "20px",
          borderRadius: "20px",
          zIndex: 2,
          fontSize: "2.5rem",
          width: "80%",
          maxWidth: "800px",
        }}
      >
        <TypingText
          text="Hey ! order food from nearby restaurants..."
          speed={80}
          style={{ fontWeight: "bold" }}
        />
      </div>
      <br />
    </div>
  );
};

export default HotelCarousel;
