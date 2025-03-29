# Utilities

This directory contains shared utility functions and helpers. This README provides guidelines for AI assistants creating utility modules.

## Utility Organization

Utilities should be organized by their purpose:

```
utils/
  ├── formatting/           # Text and data formatting utilities
  │   ├── dateFormat.ts     # Date formatting functions
  │   └── numberFormat.ts   # Number formatting functions
  ├── validation/           # Data validation utilities
  │   ├── validators.ts     # Validation functions
  │   └── schemas.ts        # Validation schemas
  ├── storage/              # Local storage utilities
  ├── http/                 # HTTP request utilities
  └── common/               # General purpose utilities
```

## Utility Design Principles

### 1. Pure Functions

Utilities should be implemented as pure functions with no side effects:

```typescript
// Good - pure function
export function formatCurrency(amount: number, currency = 'USD'): string {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency,
  }).format(amount);
}

// Avoid - function with side effects
export function formatAndStoreCurrency(amount: number): string {
  const formatted = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
  }).format(amount);
  
  localStorage.setItem('lastAmount', formatted); // Side effect
  return formatted;
}
```

### 2. Strong Typing

Utilities should use explicit typing:

```typescript
// Good - explicit typing
export function truncateText(text: string, maxLength: number): string {
  if (text.length <= maxLength) return text;
  return `${text.slice(0, maxLength - 3)}...`;
}

// Avoid - implicit typing
export function truncate(text, length) {
  if (text.length <= length) return text;
  return `${text.slice(0, length - 3)}...`;
}
```

### 3. Error Handling

Utilities should handle edge cases and errors gracefully:

```typescript
// Good - handles edge cases
export function getNestedValue<T>(
  obj: Record<string, any> | null | undefined,
  path: string,
  defaultValue: T
): T {
  if (!obj) return defaultValue;
  
  const keys = path.split('.');
  let result = obj;
  
  for (const key of keys) {
    if (result === null || result === undefined || typeof result !== 'object') {
      return defaultValue;
    }
    result = result[key];
  }
  
  return (result as unknown as T) ?? defaultValue;
}
```

### 4. Documentation

Each utility function should have clear documentation:

```typescript
/**
 * Debounces a function call to limit how often it's executed
 * 
 * @param fn - The function to debounce
 * @param delay - The delay in milliseconds
 * @returns A debounced version of the function
 * 
 * @example
 * const debouncedSearch = debounce((query) => fetchSearchResults(query), 300);
 * searchInput.addEventListener('input', (e) => debouncedSearch(e.target.value));
 */
export function debounce<T extends (...args: any[]) => any>(
  fn: T,
  delay: number
): (...args: Parameters<T>) => void {
  let timeoutId: ReturnType<typeof setTimeout> | null = null;
  
  return function(...args: Parameters<T>): void {
    if (timeoutId) {
      clearTimeout(timeoutId);
    }
    
    timeoutId = setTimeout(() => {
      fn(...args);
      timeoutId = null;
    }, delay);
  };
}
```

## Common Utility Categories

### Format Utilities

```typescript
// Date formatting
export function formatDate(date: Date | string | number, format = 'MM/DD/YYYY'): string {
  // Implementation using a date library
}

// String formatting
export function capitalize(str: string): string {
  if (!str) return '';
  return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();
}

// Number formatting
export function formatFileSize(bytes: number): string {
  if (bytes === 0) return '0 Bytes';
  
  const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
  const i = Math.floor(Math.log(bytes) / Math.log(1024));
  
  return `${parseFloat((bytes / Math.pow(1024, i)).toFixed(2))} ${sizes[i]}`;
}
```

### Validation Utilities

```typescript
// Email validation
export function isValidEmail(email: string): boolean {
  const pattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
  return pattern.test(email);
}

// Password strength validation
export function getPasswordStrength(password: string): 'weak' | 'medium' | 'strong' {
  if (!password || password.length < 8) return 'weak';
  
  const hasLetter = /[a-zA-Z]/.test(password);
  const hasNumber = /\d/.test(password);
  const hasSpecial = /[!@#$%^&*(),.?":{}|<>]/.test(password);
  
  if (hasLetter && hasNumber && hasSpecial) return 'strong';
  if ((hasLetter && hasNumber) || (hasLetter && hasSpecial) || (hasNumber && hasSpecial)) return 'medium';
  
  return 'weak';
}
```

### Array and Object Utilities

```typescript
// Group array items by property
export function groupBy<T>(array: T[], key: keyof T): Record<string, T[]> {
  return array.reduce((result, item) => {
    const groupKey = String(item[key]);
    if (!result[groupKey]) {
      result[groupKey] = [];
    }
    result[groupKey].push(item);
    return result;
  }, {} as Record<string, T[]>);
}

// Deep clone an object
export function deepClone<T>(obj: T): T {
  if (obj === null || typeof obj !== 'object') {
    return obj;
  }
  
  if (Array.isArray(obj)) {
    return obj.map(deepClone) as unknown as T;
  }
  
  return Object.entries(obj).reduce((result, [key, value]) => {
    result[key as keyof T] = deepClone(value);
    return result;
  }, {} as T);
}
```

## Testing Requirements

All utility functions should have comprehensive tests:

1. Test correct behavior with valid inputs
2. Test edge cases (empty strings, null values, etc.)
3. Test error handling and default values
4. Test performance for potentially expensive operations

## Performance Considerations

- Memoize expensive calculations
- Optimize critical utility functions
- Avoid unnecessary object creation or iteration
- Consider time and space complexity 