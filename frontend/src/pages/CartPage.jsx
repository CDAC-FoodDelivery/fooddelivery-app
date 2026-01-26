import { useCart } from "../context/CartContext";
import CartItem from "../components/CartItem";

const CartPage = () => {
  const { cartItems, totalPrice } = useCart();

  if (cartItems.length === 0) {
    return <h3 style={{ margin: "100px" }}>Your cart is empty 🛒</h3>;
  }

  return (
    <div style={{ margin: "100px" }}>
      <h3>Your Cart</h3>

      {cartItems.map((item, idx) => (
        <CartItem key={idx} item={item} />
      ))}

      <hr />
      <h4>Total: ₹{totalPrice.toFixed(2)}</h4>

      <button style={{ marginTop: "20px" }}>
        Proceed to Checkout
      </button>
    </div>
  );
};

export default CartPage;
