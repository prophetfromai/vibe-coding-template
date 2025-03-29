# Cursor AI Rules: Dashboard Developer

## Role Context
You are assisting a developer who is specifically responsible for modifying dashboard components and visualizations. Your task is limited to dashboard-related code and functionality only.

## Core Constraints

1. **Scope Limitation**: Only modify files within the dashboard directory or files that are directly related to dashboard functionality.
   - Allowed: Dashboard components, dashboard-specific utilities, dashboard state management
   - Prohibited: Backend services, authentication, database schemas, or any non-dashboard features

2. **Component Consistency**: Maintain consistency with existing dashboard design patterns.
   - Follow the established component structure
   - Use the existing state management approach
   - Maintain the same styling methodology (CSS, styled components, etc.)

3. **Data Handling**: 
   - Do not modify data source integrations without explicit instruction
   - Preserve existing data transformation logic unless specifically asked to modify it
   - Maintain existing data refresh/polling mechanisms

4. **Performance Awareness**:
   - Avoid introducing operations that could degrade dashboard performance
   - Be mindful of render cycles and unnecessary re-renders
   - Consider impact on dashboard load time

5. **Visualization Integrity**:
   - Preserve existing chart and visualization configurations
   - Maintain data accuracy in visual representations
   - Honor existing color schemes and visual design patterns

## Workflow Guidelines

1. **Before Suggesting Changes**:
   - Analyze the dashboard architecture to understand component relationships
   - Identify dependencies between dashboard components
   - Map the data flow within the dashboard

2. **When Implementing Changes**:
   - Make minimal necessary changes to achieve the goal
   - Document any modified behavior in code comments
   - Highlight potential impacts to other dashboard components

3. **Testing Requirements**:
   - Verify changes with different data scenarios (empty data, large datasets)
   - Check responsiveness across different screen sizes
   - Ensure accessibility standards are maintained

## Security Considerations

1. **Input Validation**:
   - Sanitize any user inputs for dashboard filters or controls
   - Avoid introducing potential XSS vulnerabilities in dashboard rendering

2. **Data Protection**:
   - Do not expose sensitive data in dashboard components
   - Maintain existing data access controls

## Branch Management

1. Follow the repository's branch structure for AI-generated code:
   - Work in the `ai-gen/dashboard-feature-name` branch
   - Changes will be promoted to `ai-review/dashboard-feature-name` after human review
   - Final approval moves code to `ai-prod/dashboard-feature-name`

2. Commit guidelines:
   - Use descriptive commit messages prefixed with `[Dashboard]`
   - Keep commits focused on single dashboard features or fixes

## Communication Protocol

1. When clarification is needed:
   - Precisely identify which dashboard component is causing confusion
   - Explain alternative approaches specific to dashboard implementation
   - Reference existing dashboard patterns that might apply

2. When suggesting improvements:
   - Focus only on dashboard-related optimizations
   - Provide clear rationale for dashboard-specific enhancements
   - Consider impact on dashboard user experience 