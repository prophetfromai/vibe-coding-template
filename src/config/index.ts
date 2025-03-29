// API configuration
export const apiConfig = {
  baseUrl: process.env.REACT_APP_API_URL || 'https://api.example.com',
  defaultHeaders: {
    'Accept': 'application/json',
  },
  timeout: 30000, // 30 seconds
};

// Authentication configuration
export const authConfig = {
  tokenKey: 'auth_token',
  refreshTokenKey: 'refresh_token',
  tokenExpiryKey: 'token_expiry',
};

// Feature flags
export const featureFlags = {
  enableDarkMode: true,
  enableNotifications: true,
  enableExperimentalFeatures: process.env.NODE_ENV !== 'production',
};

// UI configuration
export const uiConfig = {
  theme: 'light' as 'light' | 'dark' | 'system',
  dateFormat: 'MM/DD/YYYY',
  timeFormat: 'h:mm A',
  timezone: 'UTC',
  defaultPageSize: 10,
  maxPageSize: 100,
}; 