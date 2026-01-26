import React, { useState } from 'react';
import { Link ,useNavigate} from 'react-router-dom';

function SignUp() {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [phone, setPhone] = useState('');
  const [address, setAddress] = useState('');

  const navigate = useNavigate();

    const handleSignUp = async (e) => {
      e.preventDefault();
      try {
        await axios.post('http://localhost:8083/auth/register', {
          name,
          email,
          password,
          phone,
          address,
          role: "USER"
        });
        alert("Registration Successful. Please Login.");
        navigate("/");
      } catch (error) {
        console.error("SignUp failed", error);
        alert("Registration Failed");
      }
    };

  return (
    <div style={styles.container}>
      <form style={styles.form} onSubmit={handleSignUp}>
        <h2 style={styles.title}>Create your account</h2>
        <label style={styles.label}>Name</label>
        <input
          type="text"
          value={name}
          onChange={e => setName(e.target.value)}
          style={styles.input}
        />
        <label style={styles.label}>Email</label>
        <input
          type="email"
          value={email}
          onChange={e => setEmail(e.target.value)}
          style={styles.input}
        />
        <label style={styles.label}>Password</label>
        <input
          type="password"
          value={password}
          onChange={e => setPassword(e.target.value)}
          style={styles.input}
        />
        <label style={styles.label}>Phone Number</label>
        <input
          type="tel"
          value={phone}
          onChange={e => setPhone(e.target.value)}
          style={styles.input}
        />
        <label style={styles.label}>Address</label>
        <textarea
          value={address}
          onChange={e => setAddress(e.target.value)}
          style={{ ...styles.input, height: '80px', resize: 'vertical' }}
        />
        <button type="submit" style={styles.button}>SIGN UP</button>
        <div style={styles.newUser}>
          Already have an account? <Link to="/" style={styles.registerLink}>Sign in</Link>
        </div>
      </form>
      <footer style={styles.footer}>
        ©2025-2026 Food Delivery Inc.
      </footer>
    </div>
  );
}

const styles = {
  container: {

    minHeight: '100vh',
    background: 'linear-gradient(180deg, #fffbe9 0%, #ffe0bb 100%)',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center'
  },
  form: {
    background: 'transparent',
    padding: '32px',
    borderRadius: '10px',
    boxShadow: '0 0 8px rgba(0,0,0,0.04)',
    textAlign: 'center'
  },
  title: {
    fontWeight: 'bold',
    marginBottom: '24px'
  },
  label: {
    display: 'block',
    textAlign: 'left',
    marginBottom: '6px',
    marginTop: '6px'
  },
  input: {
    width: '100%',
    padding: '10px 12px',
    borderRadius: '6px',
    border: '1px solid #f17a53ff',
    marginBottom: '6px',
    fontSize: '16px',
    outline: 'none'
  },
  button: {
    width: '100%',
    padding: '12px',
    background: '#ff6733',
    color: '#fff',
    border: 'none',
    borderRadius: '6px',
    fontWeight: 'bold',
    fontSize: '16px',
    cursor: 'pointer',
    marginTop: '12px',
    textDecoration: 'none'
  },
  newUser: {
    marginTop: '20px',
    fontSize: '15px'
  },
  registerLink: {
    color: '#ff6733',
    textDecoration: 'none'
  },
  footer: {
    marginTop: '5 px',
    fontSize: '13px',
    color: '#444'
  }
};

export default SignUp;

