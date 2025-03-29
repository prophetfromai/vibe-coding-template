import { ApiClient } from './apiClient';
import { apiConfig } from '../../config';

// Create and export the API client instance
export const apiClient = new ApiClient(apiConfig.baseUrl, apiConfig.defaultHeaders);

// Re-export the ApiClient class
export { ApiClient } from './apiClient'; 