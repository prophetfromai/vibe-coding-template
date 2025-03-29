# Configuration

This directory contains application configuration files. This README provides guidelines for AI assistants managing configuration code.

## Configuration Architecture

Configuration should be organized by environment and purpose:

```
config/
  ├── index.ts                # Main configuration export
  ├── types.ts                # Configuration type definitions
  ├── default.ts              # Default configuration
  ├── environment.ts          # Environment-specific configuration
  ├── features.ts             # Feature flag configuration
  └── constants/              # Application constants
      ├── routes.ts           # Route definitions
      ├── api.ts              # API endpoints
      └── ui.ts               # UI constants
```

## Core Configuration Patterns

### Configuration Loading Pattern

```typescript
// index.ts
import defaultConfig from './default';
import { getEnvironmentConfig } from './environment';
import { AppConfig } from './types';

// Load environment-specific configuration
const envConfig = getEnvironmentConfig();

// Merge configurations with environment taking precedence
export const config: AppConfig = {
  ...defaultConfig,
  ...envConfig,
};

// Export specific configuration sections
export const { api, auth, ui } = config;
```

### Environment Configuration Pattern

```typescript
// environment.ts
import { EnvironmentConfig } from './types';

// Get current environment
const ENV = process.env.NODE_ENV || 'development';

// Define environment-specific configurations
const environments: Record<string, EnvironmentConfig> = {
  development: {
    api: {
      baseUrl: 'http://localhost:3000/api',
      timeout: 10000,
    },
    features: {
      enableExperimentalFeatures: true,
      debugMode: true,
    },
  },
  test: {
    api: {
      baseUrl: 'http://test-api.example.com/api',
      timeout: 5000,
    },
    features: {
      enableExperimentalFeatures: true,
      debugMode: true,
    },
  },
  production: {
    api: {
      baseUrl: 'https://api.example.com/api',
      timeout: 5000,
    },
    features: {
      enableExperimentalFeatures: false,
      debugMode: false,
    },
  },
};

export function getEnvironmentConfig(): EnvironmentConfig {
  const config = environments[ENV] || environments.development;
  
  // Allow overrides from environment variables
  if (process.env.API_BASE_URL) {
    config.api.baseUrl = process.env.API_BASE_URL;
  }
  
  return config;
}
```

### Feature Flag Configuration Pattern

```typescript
// features.ts
import { FeatureFlags } from './types';

// Get base feature flags
const baseFeatures: FeatureFlags = {
  enableDarkMode: true,
  enableNotifications: true,
  enableAnalytics: process.env.NODE_ENV === 'production',
  beta: {
    newDashboard: false,
    improvedSearch: false,
  },
};

// Dynamic feature flag loading
export function loadFeatureFlags(): FeatureFlags {
  // Start with base features
  const features = { ...baseFeatures };
  
  // Add any dynamically loaded feature flags
  // For example, from localStorage or remote configuration service
  try {
    const storedFlags = localStorage.getItem('featureFlags');
    if (storedFlags) {
      const parsedFlags = JSON.parse(storedFlags);
      Object.assign(features, parsedFlags);
    }
  } catch (error) {
    console.error('Failed to load feature flags', error);
  }
  
  return features;
}
```

## Configuration Type Definitions

```typescript
// types.ts
export interface ApiConfig {
  baseUrl: string;
  timeout: number;
  version?: string;
  headers?: Record<string, string>;
}

export interface AuthConfig {
  tokenKey: string;
  loginUrl: string;
  logoutUrl: string;
  tokenRefreshInterval: number;
}

export interface UiConfig {
  theme: 'light' | 'dark' | 'system';
  animationsEnabled: boolean;
  dateFormat: string;
  timeFormat: string;
}

export interface FeatureFlags {
  enableDarkMode: boolean;
  enableNotifications: boolean;
  enableAnalytics: boolean;
  beta: {
    newDashboard: boolean;
    improvedSearch: boolean;
  };
}

export interface EnvironmentConfig {
  api: Partial<ApiConfig>;
  features: Partial<FeatureFlags>;
}

export interface AppConfig {
  api: ApiConfig;
  auth: AuthConfig;
  ui: UiConfig;
  features: FeatureFlags;
}
```

## Constants Management

Constants should be organized by domain:

```typescript
// routes.ts
export const ROUTES = {
  HOME: '/',
  DASHBOARD: '/dashboard',
  PROFILE: '/profile',
  SETTINGS: '/settings',
  AUTH: {
    LOGIN: '/auth/login',
    REGISTER: '/auth/register',
    FORGOT_PASSWORD: '/auth/forgot-password',
  },
} as const;

// api.ts
export const API_ENDPOINTS = {
  AUTH: {
    LOGIN: '/auth/login',
    LOGOUT: '/auth/logout',
    REFRESH: '/auth/refresh',
  },
  USERS: {
    BASE: '/users',
    PROFILE: '/users/profile',
    PREFERENCES: '/users/preferences',
  },
  PRODUCTS: {
    BASE: '/products',
    DETAILS: (id: string) => `/products/${id}`,
    REVIEWS: (id: string) => `/products/${id}/reviews`,
  },
} as const;

// ui.ts
export const UI_CONSTANTS = {
  BREAKPOINTS: {
    XS: 480,
    SM: 768,
    MD: 992,
    LG: 1200,
  },
  ANIMATION: {
    DURATION: {
      FAST: 150,
      NORMAL: 300,
      SLOW: 500,
    },
  },
  SPACING: {
    XS: 4,
    SM: 8,
    MD: 16,
    LG: 24,
    XL: 32,
  },
} as const;
```

## Design Principles

### 1. Environment Isolation

Configuration should be environment-specific with clear isolation:

- Development environment settings should never be used in production
- Sensitive values should be loaded from environment variables
- Default values should be safe and secure

### 2. Type Safety

All configuration should be strongly typed:

- Use TypeScript interfaces for configuration objects
- Use const assertions for constant values
- Validate configuration at runtime when loaded from external sources

### 3. Feature Toggles

Use feature flags for controlled rollout:

- Disable incomplete features in production
- Enable experimental features in development
- Support A/B testing via dynamic feature flags

### 4. Constants vs. Configuration

Follow these guidelines for distinguishing constants and configuration:

- **Constants**: Fixed values that don't change between environments (route paths, field names)
- **Configuration**: Values that vary between environments (API URLs, timeouts)

## Security Considerations

### 1. Sensitive Information

Never include sensitive information in configuration files:

```typescript
// AVOID this pattern
const config = {
  api: {
    key: 'abcd1234', // Never hardcode API keys
  },
  database: {
    password: 'secret', // Never hardcode passwords
  },
};

// PREFER this pattern
const config = {
  api: {
    key: process.env.API_KEY ?? '',
  },
  database: {
    password: process.env.DB_PASSWORD ?? '',
  },
};
```

### 2. Client vs. Server Configuration

Clearly separate client and server configuration:

- Client configuration: Exposed to browser, should contain no secrets
- Server configuration: Private, can contain sensitive information

## Testing Approach

Configuration should be tested for:

1. Correct loading from different environments
2. Proper fallback to defaults
3. Validation of required fields
4. Type safety and structural correctness 