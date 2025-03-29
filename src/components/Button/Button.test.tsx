import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import Button from './Button';

describe('Button Component', () => {
  test('renders with default props', () => {
    render(<Button>Click Me</Button>);
    
    const button = screen.getByRole('button', { name: /click me/i });
    
    expect(button).toBeInTheDocument();
    expect(button).toHaveClass('btn');
    expect(button).toHaveClass('btn-primary');
    expect(button).toHaveClass('btn-medium');
    expect(button).not.toHaveClass('btn-full-width');
    expect(button).not.toBeDisabled();
  });

  test('renders with custom variant', () => {
    render(<Button variant="secondary">Secondary Button</Button>);
    
    const button = screen.getByRole('button', { name: /secondary button/i });
    
    expect(button).toHaveClass('btn-secondary');
    expect(button).not.toHaveClass('btn-primary');
  });

  test('renders with custom size', () => {
    render(<Button size="large">Large Button</Button>);
    
    const button = screen.getByRole('button', { name: /large button/i });
    
    expect(button).toHaveClass('btn-large');
    expect(button).not.toHaveClass('btn-medium');
  });

  test('renders full width button', () => {
    render(<Button fullWidth>Full Width Button</Button>);
    
    const button = screen.getByRole('button', { name: /full width button/i });
    
    expect(button).toHaveClass('btn-full-width');
  });

  test('renders disabled button', () => {
    render(<Button disabled>Disabled Button</Button>);
    
    const button = screen.getByRole('button', { name: /disabled button/i });
    
    expect(button).toBeDisabled();
  });

  test('renders loading button', () => {
    render(<Button isLoading>Loading Button</Button>);
    
    const button = screen.getByRole('button', { name: /loading button/i });
    const spinner = screen.getByClass('btn-spinner');
    
    expect(button).toHaveClass('btn-loading');
    expect(button).toBeDisabled();
    expect(spinner).toBeInTheDocument();
  });

  test('calls onClick when clicked', () => {
    const handleClick = jest.fn();
    
    render(<Button onClick={handleClick}>Clickable Button</Button>);
    
    const button = screen.getByRole('button', { name: /clickable button/i });
    fireEvent.click(button);
    
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  test('does not call onClick when disabled', () => {
    const handleClick = jest.fn();
    
    render(<Button disabled onClick={handleClick}>Disabled Button</Button>);
    
    const button = screen.getByRole('button', { name: /disabled button/i });
    fireEvent.click(button);
    
    expect(handleClick).not.toHaveBeenCalled();
  });

  test('does not call onClick when loading', () => {
    const handleClick = jest.fn();
    
    render(<Button isLoading onClick={handleClick}>Loading Button</Button>);
    
    const button = screen.getByRole('button', { name: /loading button/i });
    fireEvent.click(button);
    
    expect(handleClick).not.toHaveBeenCalled();
  });
}); 