import { useCart } from "../context/CartContext";

const CartItem = ({ item }) => {
  const { updateQuantity, removeFromCart } = useCart();

  return (
    <div className="cart-item">
      <img src={item.image} alt={item.name} />
      <div>
        <h6>{item.name}</h6>
        <p>₹{item.price}</p>

        <button onClick={() => updateQuantity(item.name, item.quantity - 1)}>
          -
        </button>

        <span>{item.quantity}</span>

        <button onClick={() => updateQuantity(item.name, item.quantity + 1)}>
          +
        </button>

        <button onClick={() => removeFromCart(item.name)}>
          Remove
        </button>
      </div>
    </div>
  );
};

export default CartItem;
