import React from 'react';
import './App.css';

const App: React.FC = () => {
  return (
    <div className="app">
      <header className="app-header">
        <h1>AI Code Assistant Template</h1>
        <p>A safe framework for working with AI-generated code</p>
      </header>
      <main className="app-main">
        <section className="app-section">
          <h2>Core Principles</h2>
          <ul>
            <li>Branch Isolation - AI-generated code exists only in dedicated branches</li>
            <li>Progressive Validation - Multiple verification stages before production</li>
            <li>Explicit Intent - Clear specifications communicated to AI assistants</li>
            <li>Defensible Design - Architectural patterns that limit scope and risk</li>
            <li>Continuous Verification - Automated checks for security and quality</li>
          </ul>
        </section>
      </main>
      <footer className="app-footer">
        <p>Refer to the documentation for more information on working with this template.</p>
      </footer>
    </div>
  );
};

export default App; 