import React, { useState, useEffect } from "react";
import TypingText from "./TypingText"; // Import your TypingText component (adjust path if needed)

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
    }, 3000); // Increased interval to 3s for better visibility with typing (adjust as needed)
    return () => clearInterval(timer);
  }, []);

  return (
    <div
      style={{
        // marginLeft: 200,
        // marginTop: 70,
        // marginRight: 100,
        width: "100%",
        height: "700px",
        overflow: "hidden",
        borderRadius: "20px",
        marginBottom: "32px",
        position: "relative", // Make container relative for absolute positioning
      }}
    >
      <img
        src={slides[index]}
        alt="Hotel slide"
        style={{
          width: "100%",
          height: "100%",
          objectFit: "cover",
          transition: "opacity 0.8s ease", // Changed to opacity for smoother fade (optional)
          opacity: 1, // Ensures full opacity after transition
        }}
      />

      {/* Overlay for typing text (absolute positioned) */}
      <div
        style={{
          position: "absolute",
          top: "15%",
          left: "30%",
          transform: "translate(-50%, -50%)", // Center the text
          textAlign: "center",
          color: "#ffffff", // White text for visibility on images
          backgroundColor: "rgba(0, 0, 0, 0)", // Semi-transparent background for readability
          padding: "20px",
          borderRadius: "20px",
          zIndex: 2, // Above the image
          fontSize: "2.5rem", // Large font for impact
          width: "80%", // Adjust width as needed
          maxWidth: "800px",
        }}
      >
        <TypingText
          text="Hey ! order food from nearby restaurants..."
          speed={80} // Adjust speed for typing effect
          style={{ fontWeight: "bold" }} // Optional styling
        />
      </div>
      <br />
    </div>
  );
};

export default HotelCarousel;