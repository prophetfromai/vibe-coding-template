import { ButtonHTMLAttributes, ReactNode } from 'react';

export type ButtonVariant = 'primary' | 'secondary' | 'outline' | 'text';
export type ButtonSize = 'small' | 'medium' | 'large';

export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  /**
   * Button contents
   */
  children: ReactNode;
  
  /**
   * Button variant style
   */
  variant?: ButtonVariant;
  
  /**
   * Button size
   */
  size?: ButtonSize;
  
  /**
   * Is button full width
   */
  fullWidth?: boolean;
  
  /**
   * Optional icon to display
   */
  icon?: ReactNode;
  
  /**
   * Icon position
   */
  iconPosition?: 'left' | 'right';
  
  /**
   * Is button in loading state
   */
  isLoading?: boolean;
} 