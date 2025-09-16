import React, { useState, useEffect } from 'react';
import DashboardHeader from './components/DashboardHeader';
import WelcomeSection from './components/WelcomeSection';
import './App.css';

const App: React.FC = () => {
  const [userEmail, setUserEmail] = useState('demo@example.com');

  useEffect(() => {
    // Get user email from session storage or use default
    const storedEmail = sessionStorage.getItem('userEmail');
    if (storedEmail) {
      setUserEmail(storedEmail);
    }
  }, []);

  const handleLogout = () => {
    sessionStorage.clear();
    alert('Logout clicked! In a full application, this would redirect to the login module.');
  };

  return (
    <div className="app">
      <DashboardHeader userEmail={userEmail} onLogout={handleLogout} />
      <WelcomeSection />
    </div>
  );
};

export default App;
