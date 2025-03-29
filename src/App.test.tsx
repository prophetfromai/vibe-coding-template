import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import App from './App';

describe('App Component', () => {
  test('renders page title', () => {
    render(<App />);
    const titleElement = screen.getByText(/AI Code Assistant Template/i);
    expect(titleElement).toBeInTheDocument();
  });

  test('renders core principles', () => {
    render(<App />);
    const headingElement = screen.getByText(/Core Principles/i);
    expect(headingElement).toBeInTheDocument();
    
    const branchIsolationItem = screen.getByText(/Branch Isolation/i);
    expect(branchIsolationItem).toBeInTheDocument();
  });
}); 