# UI Components

This directory contains reusable UI components for the application. This README provides guidelines for AI assistants creating UI components.

## Component Architecture

### Component Structure

Each component should follow this organization:

```
ComponentName/
  ├── ComponentName.tsx       # Component implementation
  ├── ComponentName.test.tsx  # Component tests
  ├── ComponentName.types.ts  # Component type definitions
  ├── ComponentName.styles.ts # Component styles
  └── index.ts                # Public exports
```

### Component Implementation Pattern

```tsx
// Button.tsx
import React from 'react';
import { ButtonProps } from './Button.types';
import { buttonStyles } from './Button.styles';

export const Button: React.FC<ButtonProps> = ({
  children,
  variant = 'primary',
  size = 'medium',
  disabled = false,
  onClick,
  ...props
}) => {
  return (
    <button
      className={buttonStyles({ variant, size, disabled })}
      disabled={disabled}
      onClick={disabled ? undefined : onClick}
      {...props}
    >
      {children}
    </button>
  );
};
```

## Component Design Principles

### 1. Props Interface

Every component must have a well-defined props interface:

```tsx
// Good - explicit props interface
interface UserCardProps {
  username: string;
  email: string;
  avatarUrl?: string;
  onProfileClick?: (userId: string) => void;
}

// Avoid - implicit or any types
interface BadProps {
  data: any;
  actions: any;
}
```

### 2. Controlled vs Uncontrolled

Be explicit about whether a component is controlled or uncontrolled:

```tsx
// Controlled component
const ControlledInput: React.FC<{
  value: string;
  onChange: (value: string) => void;
}> = ({ value, onChange }) => (
  <input
    value={value}
    onChange={(e) => onChange(e.target.value)}
  />
);

// Uncontrolled component with ref
const UncontrolledInput = React.forwardRef<
  HTMLInputElement,
  { defaultValue?: string }
>((props, ref) => (
  <input ref={ref} defaultValue={props.defaultValue} />
));
```

### 3. Composition Over Configuration

Prefer component composition over complex configuration:

```tsx
// Good - component composition
<Card>
  <Card.Header>User Profile</Card.Header>
  <Card.Body>
    <UserProfile user={user} />
  </Card.Body>
  <Card.Footer>
    <Button onClick={handleEdit}>Edit</Button>
  </Card.Footer>
</Card>

// Avoid - excessive props configuration
<Card 
  title="User Profile"
  content={<UserProfile user={user} />}
  footer={<Button onClick={handleEdit}>Edit</Button>}
/>
```

### 4. Accessibility

Components must adhere to accessibility standards:

- Use semantic HTML elements (`button`, `nav`, `article`, etc.)
- Include ARIA attributes when necessary
- Support keyboard navigation
- Maintain appropriate color contrast
- Manage focus states properly

### 5. Error Handling

Components should gracefully handle missing or invalid props:

```tsx
const UserProfile: React.FC<UserProfileProps> = ({ 
  user, 
  showDetails = false 
}) => {
  // Handle missing user data
  if (!user) {
    return <div className="user-profile-skeleton">Loading...</div>;
  }

  // Handle incomplete user data
  const displayName = user.name || 'Unknown User';
  
  return (
    <div className="user-profile">
      <h2>{displayName}</h2>
      {showDetails && (
        <div className="user-details">
          {user.email && <p>Email: {user.email}</p>}
          {/* Other user details */}
        </div>
      )}
    </div>
  );
};
```

## State Management

- Local component state for UI-specific concerns
- Props for parent-controlled data
- Context for theme, authentication, or other global states
- Avoid direct store access within components

## Testing Requirements

Every component should have tests covering:

1. Basic rendering
2. Props variations
3. User interactions
4. Edge cases and error states

## Performance Considerations

- Use memoization for expensive computations
- Implement virtualization for long lists
- Lazy load components when appropriate
- Optimize re-renders with React.memo or useMemo/useCallback 