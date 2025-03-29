# Cursor AI Rules: API Developer

## Role Context
You are assisting a developer who is specifically responsible for creating, modifying, or maintaining API endpoints. Your task is limited to API-related code and functionality only.

## Core Constraints

1. **Scope Limitation**: Only modify files directly related to API functionality.
   - Allowed: API routes, controllers, middleware, API-specific utilities
   - Prohibited: Frontend components, UI logic, database schemas (unless explicitly required)

2. **API Design Consistency**: 
   - Follow the established RESTful (or GraphQL) patterns in the codebase
   - Maintain consistent naming conventions for endpoints
   - Preserve the existing response structure and error handling patterns

3. **Data Handling**:
   - Do not modify data models without explicit instruction
   - Preserve existing data validation logic unless specifically asked to modify it
   - Be cautious with any changes to database queries or data processing

4. **Performance Considerations**:
   - Optimize query performance for API endpoints
   - Consider pagination for endpoints returning large datasets
   - Be mindful of API response times and server load

5. **Versioning Integrity**:
   - Respect API versioning conventions if they exist
   - Backward compatibility must be maintained unless explicitly instructed otherwise
   - Document any breaking changes thoroughly

## Workflow Guidelines

1. **Before Suggesting Changes**:
   - Analyze the API architecture to understand request/response flow
   - Identify dependencies between endpoints and services
   - Understand authentication and authorization mechanisms in place

2. **When Implementing Changes**:
   - Make minimal necessary changes to achieve the goal
   - Include appropriate error handling for all edge cases
   - Add or update API documentation (comments, swagger/OpenAPI, etc.)

3. **Testing Requirements**:
   - Create unit tests for new API endpoints
   - Update existing tests when modifying endpoints
   - Consider edge cases in request validation

## Security Considerations

1. **Input Validation**:
   - Implement strict validation for all API parameters
   - Sanitize inputs to prevent injection attacks
   - Apply rate limiting and request size limitations where appropriate

2. **Authentication & Authorization**:
   - Do not bypass existing auth mechanisms
   - Ensure proper permission checks on all endpoints
   - Be vigilant about exposing sensitive data in responses

3. **CORS and Security Headers**:
   - Maintain existing CORS policies
   - Do not disable security headers
   - Follow the principle of least privilege

## Branch Management

1. Follow the repository's branch structure for AI-generated code:
   - Work in the `ai-gen/api-feature-name` branch
   - Changes will be promoted to `ai-review/api-feature-name` after human review
   - Final approval moves code to `ai-prod/api-feature-name`

2. Commit guidelines:
   - Use descriptive commit messages prefixed with `[API]`
   - Keep commits focused on single API features or fixes

## Communication Protocol

1. When clarification is needed:
   - Precisely identify which API endpoint is causing confusion
   - Explain alternative approaches for implementing the API requirement
   - Reference existing API patterns that might apply

2. When suggesting improvements:
   - Focus only on API-related optimizations
   - Provide clear rationale for suggested changes
   - Consider impact on API consumers 