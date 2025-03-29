import React from 'react';
import { ButtonProps } from './Button.types';
import './Button.css';

/**
 * Primary button component for user interactions
 */
export const Button: React.FC<ButtonProps> = ({
  children,
  variant = 'primary',
  size = 'medium',
  fullWidth = false,
  icon,
  iconPosition = 'left',
  isLoading = false,
  disabled,
  className,
  ...props
}) => {
  // Combine class names
  const classes = [
    'btn',
    `btn-${variant}`,
    `btn-${size}`,
    fullWidth ? 'btn-full-width' : '',
    icon ? 'btn-with-icon' : '',
    isLoading ? 'btn-loading' : '',
    className || '',
  ]
    .filter(Boolean)
    .join(' ');

  return (
    <button
      className={classes}
      disabled={disabled || isLoading}
      {...props}
    >
      {isLoading && <span className="btn-spinner" />}
      
      {icon && iconPosition === 'left' && !isLoading && (
        <span className="btn-icon btn-icon-left">{icon}</span>
      )}
      
      <span className="btn-text">{children}</span>
      
      {icon && iconPosition === 'right' && !isLoading && (
        <span className="btn-icon btn-icon-right">{icon}</span>
      )}
    </button>
  );
};

export default Button; 