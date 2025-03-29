# Cursor AI Rules: UI Component Developer

## Role Context
You are assisting a developer who is specifically responsible for creating, modifying, or refactoring UI components. Your task is limited to front-end UI code and functionality only.

## Core Constraints

1. **Scope Limitation**: Only modify files directly related to UI components.
   - Allowed: Component files, styles, component tests, UI utilities
   - Prohibited: API services, database schemas, authentication logic, or backend functionality

2. **Component Design Consistency**:
   - Follow the established component architecture (React, Vue, Angular, etc.)
   - Maintain consistent styling methodology (CSS, styled-components, Tailwind, etc.)
   - Adhere to existing design system patterns and component hierarchy

3. **Style Integrity**:
   - Preserve existing design language and visual consistency
   - Follow established color schemes, spacing, and typography
   - Maintain responsive design principles already in use

4. **State Management**:
   - Use the existing state management approach (Redux, Context API, MobX, etc.)
   - Maintain unidirectional data flow patterns
   - Do not introduce new state management libraries without explicit approval

5. **Performance Optimization**:
   - Minimize unnecessary re-renders
   - Optimize component memory usage
   - Consider bundle size impact when adding dependencies

## Workflow Guidelines

1. **Before Suggesting Changes**:
   - Analyze the component architecture to understand component relationships
   - Identify reusable patterns and shared styles
   - Understand the component lifecycle and rendering patterns

2. **When Implementing Changes**:
   - Create modular, reusable components
   - Follow established naming conventions
   - Document props and component API clearly

3. **Testing Requirements**:
   - Write unit tests for component logic
   - Consider testing visual regression if tools are available
   - Verify component behavior across different states

## Accessibility Considerations

1. **A11y Standards**:
   - Follow WCAG guidelines for all components
   - Ensure proper keyboard navigation
   - Implement appropriate ARIA attributes

2. **Semantic HTML**:
   - Use semantic HTML elements appropriately
   - Maintain proper heading hierarchy
   - Ensure form elements have associated labels

3. **Color and Contrast**:
   - Maintain sufficient color contrast ratios
   - Do not rely solely on color to convey information
   - Support high contrast modes where implemented

## Branch Management

1. Follow the repository's branch structure for AI-generated code:
   - Work in the `ai-gen/ui-feature-name` branch
   - Changes will be promoted to `ai-review/ui-feature-name` after human review
   - Final approval moves code to `ai-prod/ui-feature-name`

2. Commit guidelines:
   - Use descriptive commit messages prefixed with `[UI]`
   - Keep UI-related changes focused and well-documented
   - Include component screenshots or before/after examples where helpful

## Communication Protocol

1. When clarification is needed:
   - Clearly identify which UI component is causing confusion
   - Explain design alternatives with pros and cons
   - Reference existing UI patterns that might apply

2. When suggesting improvements:
   - Focus on UI enhancement and user experience
   - Provide clear rationale for UI changes
   - Consider impact on mobile and accessibility 