import React, { useState } from 'react';

interface LoginFormProps {
  onLogin: (email: string) => void;
}

const LoginForm: React.FC<LoginFormProps> = ({ onLogin }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  const sanitizeInput = (input: string): string => {
    return input.trim().replace(/[<>]/g, '');
  };

  const validateEmail = (email: string): boolean => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  };

  const validatePassword = (password: string): boolean => {
    const passwordRegex = /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{8,}$/;
    return passwordRegex.test(password);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    const sanitizedEmail = sanitizeInput(email);
    const sanitizedPassword = sanitizeInput(password);

    if (!sanitizedEmail || !sanitizedPassword) {
      setError('Please enter both email and password');
      return;
    }

    if (!validateEmail(sanitizedEmail)) {
      setError('Please enter a valid email address');
      return;
    }

    if (!validatePassword(sanitizedPassword)) {
      setError('Password must be at least 8 characters with letters and numbers');
      return;
    }

    onLogin(sanitizedEmail);
  };

  return (
    <div className="login-container">
      <div className="login-box">
        <h1>Login Module</h1>
        <p className="subtitle">Please sign in to your account</p>
        
        <form className="login-form" onSubmit={handleSubmit}>
          <div className="form-group">
            <label htmlFor="email">Email Address</label>
            <input
              type="email"
              id="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="Enter your email"
              required
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="password">Password</label>
            <input
              type="password"
              id="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="Enter your password"
              required
            />
          </div>
          
          <button type="submit" className="login-btn">
            Sign In
          </button>
        </form>
        
        {error && (
          <div className="error-message">
            {error}
          </div>
        )}
        
        <div className="demo-note">
          <p><strong>Demo Mode:</strong> Click "Sign In" to proceed</p>
          <p><strong>Password Requirements:</strong> At least 8 characters with letters and numbers</p>
        </div>
      </div>
    </div>
  );
};

export default LoginForm;
