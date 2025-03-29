# Services

This directory contains business logic, API integrations, and data operations. This README provides guidelines for AI assistants creating service modules.

## Service Architecture

Services should follow these organizational patterns:

```
services/
  ├── api/                 # API client and request handling
  │   ├── apiClient.ts     # Base API client configuration
  │   └── endpoints/       # API endpoint definitions
  ├── domain/              # Business logic organized by domain
  │   ├── users/           # User-related business logic
  │   └── products/        # Product-related business logic
  └── utils/               # Service-specific utilities
```

## Core Service Patterns

### API Client Pattern

```typescript
// apiClient.ts
import axios, { AxiosInstance, AxiosRequestConfig, AxiosResponse } from 'axios';

export class ApiClient {
  private client: AxiosInstance;
  
  constructor(baseURL: string, options: AxiosRequestConfig = {}) {
    this.client = axios.create({
      baseURL,
      timeout: 10000,
      headers: {
        'Content-Type': 'application/json',
      },
      ...options,
    });
    
    this.setupInterceptors();
  }
  
  private setupInterceptors(): void {
    // Request interceptor
    this.client.interceptors.request.use(
      (config) => {
        // Add auth token if available
        const token = localStorage.getItem('auth_token');
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
      },
      (error) => Promise.reject(error)
    );
    
    // Response interceptor
    this.client.interceptors.response.use(
      (response) => response,
      (error) => {
        // Handle common errors (401, 403, 500, etc)
        return Promise.reject(error);
      }
    );
  }
  
  async get<T>(url: string, config?: AxiosRequestConfig): Promise<T> {
    const response: AxiosResponse<T> = await this.client.get(url, config);
    return response.data;
  }
  
  async post<T>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> {
    const response: AxiosResponse<T> = await this.client.post(url, data, config);
    return response.data;
  }
  
  // Additional methods (put, delete, etc.)
}
```

### Service Implementation Pattern

```typescript
// userService.ts
import { ApiClient } from '../api/apiClient';
import { User, UserCreateDto, UserUpdateDto } from './types';

export class UserService {
  private apiClient: ApiClient;
  private baseUrl = '/users';
  
  constructor(apiClient: ApiClient) {
    this.apiClient = apiClient;
  }
  
  async getUsers(): Promise<User[]> {
    try {
      return await this.apiClient.get<User[]>(this.baseUrl);
    } catch (error) {
      // Handle and transform errors
      throw this.handleError(error, 'Failed to fetch users');
    }
  }
  
  async getUserById(id: string): Promise<User> {
    try {
      return await this.apiClient.get<User>(`${this.baseUrl}/${id}`);
    } catch (error) {
      throw this.handleError(error, `Failed to fetch user with ID ${id}`);
    }
  }
  
  async createUser(userData: UserCreateDto): Promise<User> {
    try {
      return await this.apiClient.post<User>(this.baseUrl, userData);
    } catch (error) {
      throw this.handleError(error, 'Failed to create user');
    }
  }
  
  // Additional methods
  
  private handleError(error: any, defaultMessage: string): Error {
    // Transform API errors into consistent format
    const message = error.response?.data?.message || defaultMessage;
    const errorObj = new Error(message);
    errorObj.name = 'UserServiceError';
    return errorObj;
  }
}
```

## Design Principles

### 1. Clear Domain Boundaries

Each service should represent a clear domain concept:

- `UserService` - User management operations
- `AuthService` - Authentication and authorization
- `ProductService` - Product data operations

### 2. Error Handling

Service methods should implement comprehensive error handling:

- Catch and transform API errors
- Provide meaningful error messages
- Include necessary context for debugging
- Return typed error objects

### 3. Data Validation

Validate data before sending to APIs:

```typescript
import { z } from 'zod';

// Define schema
const userSchema = z.object({
  name: z.string().min(2),
  email: z.string().email(),
  age: z.number().min(18).optional(),
});

// Validate before API call
async function createUser(userData: unknown): Promise<User> {
  // Validate and transform input
  const validatedData = userSchema.parse(userData);
  
  // Proceed with API call
  return await apiClient.post<User>('/users', validatedData);
}
```

### 4. Caching Strategy

Implement appropriate caching strategies:

```typescript
export class CachedProductService {
  private cache = new Map<string, { data: Product; timestamp: number }>();
  private cacheTTL = 5 * 60 * 1000; // 5 minutes
  
  async getProduct(id: string): Promise<Product> {
    // Check cache first
    const cached = this.cache.get(id);
    const now = Date.now();
    
    if (cached && now - cached.timestamp < this.cacheTTL) {
      return cached.data;
    }
    
    // Fetch from API if not cached or expired
    const product = await this.apiClient.get<Product>(`/products/${id}`);
    
    // Update cache
    this.cache.set(id, { data: product, timestamp: now });
    
    return product;
  }
}
```

### 5. Service Composition

Complex business logic should be composed from smaller services:

```typescript
export class OrderService {
  constructor(
    private userService: UserService,
    private productService: ProductService,
    private paymentService: PaymentService
  ) {}
  
  async createOrder(userId: string, productIds: string[], paymentDetails: PaymentDetails): Promise<Order> {
    // Get user
    const user = await this.userService.getUserById(userId);
    
    // Get products
    const products = await Promise.all(
      productIds.map(id => this.productService.getProduct(id))
    );
    
    // Calculate total
    const total = products.reduce((sum, product) => sum + product.price, 0);
    
    // Process payment (this should never be implemented by AI)
    const paymentResult = await this.paymentService.processPayment(paymentDetails, total);
    
    // Create order record
    return await this.apiClient.post<Order>('/orders', {
      userId,
      products: products.map(p => p.id),
      total,
      paymentId: paymentResult.id,
      status: 'confirmed'
    });
  }
}
```

## Testing Approach

Services should be tested with:

1. Unit tests with mocked dependencies
2. Integration tests for API interactions
3. Edge case testing for error handling

## Security Guidelines

- Never store sensitive data in the service code
- Always validate and sanitize user input
- Use environment variables for configuration
- Implement proper authentication handling
- Log errors without exposing sensitive information 