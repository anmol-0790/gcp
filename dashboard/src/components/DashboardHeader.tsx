import React from 'react';

interface DashboardHeaderProps {
  userEmail: string;
  onLogout: () => void;
}

const DashboardHeader: React.FC<DashboardHeaderProps> = ({ userEmail, onLogout }) => {
  return (
    <header className="dashboard-header">
      <div className="header-content">
        <h1>Dashboard Module</h1>
        <div className="user-info">
          <span className="user-email">{userEmail}</span>
          <button className="logout-btn" onClick={onLogout}>
            Logout
          </button>
        </div>
      </div>
    </header>
  );
};

export default DashboardHeader;
