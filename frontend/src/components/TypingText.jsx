import React, { useState, useEffect } from 'react';

const TypingText = ({ text, speed = 100, style = {} }) => {
  const [displayedText, setDisplayedText] = useState('');
  const [index, setIndex] = useState(0);

  useEffect(() => {
    if (index < text.length) {
      const timer = setTimeout(() => {
        setDisplayedText((prev) => prev + text[index]);
        setIndex(index + 1);
      }, speed);

      return () => clearTimeout(timer); // Cleanup to avoid memory leaks
    }
  }, [index, text, speed]); // Re-run effect when index changes

  return <span style={{ ...style }}>{displayedText}</span>; // Use span for inline, or change to h1/p as needed
};

export default TypingText;