import React from 'react';
import FeatureCard from './FeatureCard';

const WelcomeSection: React.FC = () => {
  const features = [
    {
      icon: '🚀',
      title: 'Fast & Secure',
      description: 'Built with modern web technologies and deployed on GCP Compute Engine'
    },
    {
      icon: '🐳',
      title: 'Dockerized',
      description: 'Containerized application for easy deployment and scaling'
    },
    {
      icon: '⚡',
      title: 'Nginx Powered',
      description: 'High-performance web server for optimal delivery'
    }
  ];

  return (
    <main className="dashboard-main">
      <div className="welcome-section">
        <div className="welcome-card">
          <div className="welcome-icon">🎉</div>
          <h2>Welcome to Your Dashboard!</h2>
          <p className="welcome-message">
            You are now viewing the Dashboard Module. This is a standalone React application 
            running on Google Cloud Platform Compute Engine.
          </p>
          <div className="features-grid">
            {features.map((feature, index) => (
              <FeatureCard
                key={index}
                icon={feature.icon}
                title={feature.title}
                description={feature.description}
              />
            ))}
          </div>
        </div>
      </div>
    </main>
  );
};

export default WelcomeSection;
