import React, { useState, useEffect } from 'react';
import LoginForm from './components/LoginForm';
import './App.css';

const App: React.FC = () => {
  const [isLoggedIn, setIsLoggedIn] = useState(false);

  useEffect(() => {
    // Check if user is already logged in
    const loginStatus = sessionStorage.getItem('isLoggedIn');
    if (loginStatus === 'true') {
      setIsLoggedIn(true);
    }
  }, []);

  const handleLogin = (email: string) => {
    sessionStorage.setItem('userEmail', email);
    sessionStorage.setItem('isLoggedIn', 'true');
    sessionStorage.setItem('loginTime', new Date().toISOString());
    setIsLoggedIn(true);
  };

  const handleLogout = () => {
    sessionStorage.clear();
    setIsLoggedIn(false);
  };

  if (isLoggedIn) {
    return (
      <div className="app">
        <div className="success-container">
          <div className="success-box">
            <h1>Login Successful!</h1>
            <p>You are now logged in to the Login Module.</p>
            <p>In a full application, you would be redirected to the dashboard.</p>
            <button className="logout-btn" onClick={handleLogout}>
              Logout
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="app">
      <LoginForm onLogin={handleLogin} />
    </div>
  );
};

export default App;
