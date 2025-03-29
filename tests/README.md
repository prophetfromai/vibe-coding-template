# Testing Guidelines

This directory contains test files and testing utilities. This README provides guidelines for testing AI-generated code.

## Testing Structure

Tests should be organized to mirror the source code structure:

```
tests/
  ├── unit/                    # Unit tests
  │   ├── components/          # Component tests
  │   ├── services/            # Service tests
  │   └── utils/               # Utility tests
  ├── integration/             # Integration tests
  │   ├── api/                 # API integration tests
  │   └── features/            # Feature integration tests
  ├── e2e/                     # End-to-end tests
  ├── fixtures/                # Test data
  │   ├── users.ts             # User test data
  │   └── products.ts          # Product test data
  └── utils/                   # Test utilities
      ├── mocks.ts             # Mock implementations
      └── testHelpers.ts       # Helper functions
```

## Testing Requirements for AI-Generated Code

AI-generated code must include comprehensive tests following these guidelines:

### 1. Test Coverage Requirements

| Test Type | Required Coverage | Notes |
|-----------|------------------|-------|
| Unit Tests | 95%+ | Complete coverage of business logic and utilities |
| Component Tests | 90%+ | All component states and interactions |
| Integration Tests | 80%+ | Key integration points and data flows |
| E2E Tests | Critical paths | Main user journeys |

### 2. Test Types and Purposes

#### Unit Tests

For isolated, focused testing of individual functions, components, or classes:

```typescript
// Example unit test for a utility function
describe('formatCurrency', () => {
  it('should format valid numbers with default currency', () => {
    expect(formatCurrency(1000)).toBe('$1,000.00');
    expect(formatCurrency(1234.56)).toBe('$1,234.56');
    expect(formatCurrency(0)).toBe('$0.00');
  });

  it('should handle negative numbers', () => {
    expect(formatCurrency(-1000)).toBe('-$1,000.00');
  });

  it('should support different currencies', () => {
    expect(formatCurrency(1000, 'EUR')).toBe('€1,000.00');
    expect(formatCurrency(1000, 'JPY')).toBe('¥1,000');
  });

  it('should handle invalid inputs', () => {
    expect(formatCurrency(NaN)).toBe('$0.00');
    expect(formatCurrency(Infinity)).toBe('$0.00');
  });
});
```

#### Component Tests

For testing UI components in isolation:

```typescript
// Example component test
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from '../../src/components/Button';

describe('Button', () => {
  it('should render with default props', () => {
    render(<Button>Click Me</Button>);
    const button = screen.getByRole('button', { name: /click me/i });
    expect(button).toBeInTheDocument();
    expect(button).toHaveClass('btn-primary');
    expect(button).not.toBeDisabled();
  });

  it('should render with custom variant', () => {
    render(<Button variant="secondary">Secondary</Button>);
    const button = screen.getByRole('button', { name: /secondary/i });
    expect(button).toHaveClass('btn-secondary');
  });

  it('should be disabled when disabled prop is true', () => {
    render(<Button disabled>Disabled</Button>);
    const button = screen.getByRole('button', { name: /disabled/i });
    expect(button).toBeDisabled();
  });

  it('should call onClick handler when clicked', () => {
    const handleClick = jest.fn();
    render(<Button onClick={handleClick}>Click Me</Button>);
    const button = screen.getByRole('button', { name: /click me/i });
    
    fireEvent.click(button);
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('should not call onClick when disabled and clicked', () => {
    const handleClick = jest.fn();
    render(<Button disabled onClick={handleClick}>Click Me</Button>);
    const button = screen.getByRole('button', { name: /click me/i });
    
    fireEvent.click(button);
    expect(handleClick).not.toHaveBeenCalled();
  });
});
```

#### Integration Tests

For testing interactions between different parts of the application:

```typescript
// Example integration test
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { UserProfile } from '../../src/components/UserProfile';
import { UserService } from '../../src/services/UserService';
import { mockUser } from '../fixtures/users';

// Mock the service module
jest.mock('../../src/services/UserService');

describe('UserProfile Integration', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should fetch and display user profile', async () => {
    // Set up mocks
    UserService.getUserProfile = jest.fn().mockResolvedValue(mockUser);
    
    // Render component
    render(<UserProfile userId="user123" />);
    
    // Verify loading state
    expect(screen.getByText(/loading/i)).toBeInTheDocument();
    
    // Verify service was called with correct parameters
    expect(UserService.getUserProfile).toHaveBeenCalledWith('user123');
    
    // Verify data display after loading
    await waitFor(() => {
      expect(screen.queryByText(/loading/i)).not.toBeInTheDocument();
      expect(screen.getByText(mockUser.name)).toBeInTheDocument();
      expect(screen.getByText(mockUser.email)).toBeInTheDocument();
    });
  });

  it('should handle error states', async () => {
    // Set up mocks for error case
    UserService.getUserProfile = jest.fn().mockRejectedValue(
      new Error('Failed to fetch user')
    );
    
    // Render component
    render(<UserProfile userId="user123" />);
    
    // Verify error state after loading
    await waitFor(() => {
      expect(screen.queryByText(/loading/i)).not.toBeInTheDocument();
      expect(screen.getByText(/error/i)).toBeInTheDocument();
      expect(screen.getByText(/failed to fetch user/i)).toBeInTheDocument();
    });
  });
});
```

#### E2E Tests

For testing complete user flows:

```typescript
// Example E2E test using Cypress
describe('User Authentication', () => {
  beforeEach(() => {
    cy.visit('/login');
  });

  it('should allow a user to login and access dashboard', () => {
    // Fill in login form
    cy.get('[data-testid="email-input"]').type('user@example.com');
    cy.get('[data-testid="password-input"]').type('password123');
    cy.get('[data-testid="login-button"]').click();
    
    // Verify redirect to dashboard
    cy.url().should('include', '/dashboard');
    
    // Verify user is logged in
    cy.get('[data-testid="user-menu"]').should('contain', 'John Doe');
    
    // Verify dashboard content is loaded
    cy.get('[data-testid="dashboard-title"]').should('be.visible');
    cy.get('[data-testid="recent-activity"]').should('exist');
  });

  it('should show validation errors for invalid input', () => {
    // Submit with invalid email
    cy.get('[data-testid="email-input"]').type('invalid-email');
    cy.get('[data-testid="password-input"]').type('password123');
    cy.get('[data-testid="login-button"]').click();
    
    // Verify validation error
    cy.get('[data-testid="email-error"]').should('be.visible')
      .and('contain', 'valid email');
    
    // URL should still be login page
    cy.url().should('include', '/login');
  });

  it('should show error message for incorrect credentials', () => {
    // Submit with incorrect password
    cy.get('[data-testid="email-input"]').type('user@example.com');
    cy.get('[data-testid="password-input"]').type('wrong-password');
    cy.get('[data-testid="login-button"]').click();
    
    // Verify error message
    cy.get('[data-testid="login-error"]').should('be.visible')
      .and('contain', 'Invalid credentials');
    
    // URL should still be login page
    cy.url().should('include', '/login');
  });
});
```

## Test Design Principles

### 1. Independence

Tests should be independent of each other:

- Each test should run in isolation
- Tests should not depend on the state from previous tests
- Setup and teardown should ensure clean state

### 2. Comprehensive Test Cases

Tests should cover all important scenarios:

- Happy path (expected inputs, successful operation)
- Edge cases (boundary values, empty values)
- Error cases (invalid inputs, API failures)
- Async behaviors (loading states, race conditions)
- Side effects (state changes, DOM updates)

### 3. Test Data Management

Test data should be managed properly:

- Use fixtures for test data
- Avoid hardcoding test data in tests
- Use factories to generate test data
- Reset state between tests

### 4. Mocking External Dependencies

External dependencies should be properly mocked:

```typescript
// Service mocking example
jest.mock('../../src/services/api', () => ({
  fetchData: jest.fn()
}));

// Using the mock in a test
import { fetchData } from '../../src/services/api';

test('component fetches data on mount', async () => {
  // Set up the mock
  (fetchData as jest.Mock).mockResolvedValue({ id: 1, name: 'Test' });
  
  // Render and test component
});
```

### 5. Snapshot Testing

Use snapshot testing judiciously:

- Snapshots are good for detecting unexpected UI changes
- Don't overuse snapshots for logic-heavy components
- Review snapshot changes carefully

## Security Testing Requirements

AI-generated code should undergo these security tests:

1. **Input Validation Testing** - Verify that all inputs are properly validated
2. **Output Encoding Testing** - Verify proper encoding of user-generated content
3. **Authentication Testing** - Verify proper authentication checks
4. **Authorization Testing** - Verify proper authorization controls
5. **Error Handling Testing** - Verify error messages don't expose sensitive info

## Performance Testing Considerations

Consider these performance aspects:

1. **Rendering Performance** - Components should render efficiently
2. **Network Request Optimization** - API calls should be minimized
3. **State Management Efficiency** - State updates should be optimized
4. **Memory Leaks** - Long-running operations should be properly cleaned up

## Test Quality Checklist

- Tests have clear, descriptive names
- Tests focus on a single behavior
- Tests are deterministic (same input → same result)
- Tests are fast to execute
- Tests provide clear failure messages
- Tests avoid unnecessary complexity 