/**
 * API Client for making HTTP requests
 * This is a simplified implementation for demonstration purposes
 */
export class ApiClient {
  private baseUrl: string;
  private defaultHeaders: Record<string, string>;

  /**
   * Create a new API client
   * @param baseUrl - Base URL for all requests
   * @param defaultHeaders - Default headers to include with all requests
   */
  constructor(
    baseUrl: string,
    defaultHeaders: Record<string, string> = {}
  ) {
    this.baseUrl = baseUrl;
    this.defaultHeaders = {
      'Content-Type': 'application/json',
      ...defaultHeaders,
    };
  }

  /**
   * Add authorization header with bearer token
   * @param token - Authentication token
   */
  setAuthToken(token: string): void {
    this.defaultHeaders.Authorization = `Bearer ${token}`;
  }

  /**
   * Remove authorization header
   */
  clearAuthToken(): void {
    delete this.defaultHeaders.Authorization;
  }

  /**
   * Make a GET request
   * @param endpoint - API endpoint
   * @param params - Query parameters
   * @param headers - Additional headers
   * @returns Promise with response data
   */
  async get<T>(
    endpoint: string,
    params?: Record<string, string>,
    headers?: Record<string, string>
  ): Promise<T> {
    const url = this.buildUrl(endpoint, params);
    const response = await fetch(url, {
      method: 'GET',
      headers: this.buildHeaders(headers),
    });

    return this.handleResponse<T>(response);
  }

  /**
   * Make a POST request
   * @param endpoint - API endpoint
   * @param data - Request body data
   * @param headers - Additional headers
   * @returns Promise with response data
   */
  async post<T>(
    endpoint: string,
    data?: unknown,
    headers?: Record<string, string>
  ): Promise<T> {
    const url = this.buildUrl(endpoint);
    const response = await fetch(url, {
      method: 'POST',
      headers: this.buildHeaders(headers),
      body: data ? JSON.stringify(data) : undefined,
    });

    return this.handleResponse<T>(response);
  }

  /**
   * Make a PUT request
   * @param endpoint - API endpoint
   * @param data - Request body data
   * @param headers - Additional headers
   * @returns Promise with response data
   */
  async put<T>(
    endpoint: string,
    data?: unknown,
    headers?: Record<string, string>
  ): Promise<T> {
    const url = this.buildUrl(endpoint);
    const response = await fetch(url, {
      method: 'PUT',
      headers: this.buildHeaders(headers),
      body: data ? JSON.stringify(data) : undefined,
    });

    return this.handleResponse<T>(response);
  }

  /**
   * Make a DELETE request
   * @param endpoint - API endpoint
   * @param headers - Additional headers
   * @returns Promise with response data
   */
  async delete<T>(
    endpoint: string,
    headers?: Record<string, string>
  ): Promise<T> {
    const url = this.buildUrl(endpoint);
    const response = await fetch(url, {
      method: 'DELETE',
      headers: this.buildHeaders(headers),
    });

    return this.handleResponse<T>(response);
  }

  /**
   * Build full URL with query parameters
   * @param endpoint - API endpoint
   * @param params - Query parameters
   * @returns Formatted URL
   */
  private buildUrl(endpoint: string, params?: Record<string, string>): string {
    const url = new URL(`${this.baseUrl}${endpoint}`);

    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        url.searchParams.append(key, value);
      });
    }

    return url.toString();
  }

  /**
   * Combine default headers with request-specific headers
   * @param headers - Request-specific headers
   * @returns Combined headers
   */
  private buildHeaders(headers?: Record<string, string>): Record<string, string> {
    return {
      ...this.defaultHeaders,
      ...headers,
    };
  }

  /**
   * Handle API response and transform to JSON
   * @param response - Fetch API response
   * @returns Parsed response data
   * @throws Error with status and message on non-2xx responses
   */
  private async handleResponse<T>(response: Response): Promise<T> {
    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      const error = new Error(
        errorData.message || `API Error: ${response.status} ${response.statusText}`
      );
      
      // Add additional error properties
      (error as any).status = response.status;
      (error as any).data = errorData;
      
      throw error;
    }

    // Handle empty responses
    if (response.status === 204 || response.headers.get('content-length') === '0') {
      return {} as T;
    }

    return await response.json() as T;
  }
} 