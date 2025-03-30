# AI Iterative Code Review Criteria

This document defines the requirements and evaluation criteria used during each iteration of the AI-powered code generation and review process.

## Evaluation Criteria by Iteration

Each iteration focuses on specific aspects of code quality, progressively refining the implementation:

### Iteration 1: Core Functionality

* Code correctly implements the required feature functionality
* All basic use cases are handled
* Appropriate error handling for common failure modes
* Initial test coverage for main functionality

### Iteration 2: Code Quality & Style

* Adheres to project code style conventions
* Uses appropriate design patterns consistent with the codebase
* No code duplication
* Clear naming conventions
* Comprehensive documentation of public APIs
* Code is modular and follows separation of concerns

### Iteration 3: Security Review

* No hard-coded secrets or sensitive data
* Input validation for all user-provided data
* Proper authentication and authorization checks
* Protection against common vulnerabilities (XSS, CSRF, injection attacks, etc.)
* Secure handling of sensitive information
* No exposure of internal implementation details

### Iteration 4: Performance Optimization

* Efficient algorithms and data structures
* Proper resource management (memory, connections, etc.)
* Optimized database queries
* No N+1 query problems
* Appropriate caching strategies
* Minimized computational complexity

### Iteration 5: Edge Cases & Resilience

* Handles edge cases and boundary conditions
* Graceful degradation under unexpected conditions
* Proper logging for debugging and monitoring
* Resilient against partial system failures
* Comprehensive test coverage including edge cases
* Appropriate retry mechanisms

## Code Conventions

### Naming Conventions

* Classes: PascalCase
* Methods/Functions: camelCase
* Variables: camelCase
* Constants: UPPER_SNAKE_CASE
* Private properties: _prefixedWithUnderscore

### Documentation Requirements

* Public APIs must include JSDoc/equivalent documentation
* Complex algorithms should include explanatory comments
* Assumptions should be documented
* File headers should describe the purpose of the module

### Testing Standards

* Unit tests for all business logic
* Integration tests for component interactions
* End-to-end tests for critical user flows
* Test coverage minimum: 80% for business logic

### Architecture Constraints

* Follow the repository's defined architecture patterns
* Respect service boundaries
* Use dependency injection for testability
* Avoid direct coupling between unrelated modules
* Follow the principle of least privilege

## Review Process

Each iteration should produce a report documenting:

1. What was evaluated
2. Issues found
3. Changes made
4. Recommendations for future iterations

The final iteration should include a comprehensive summary of all changes and a quality assessment against each category. 