# Cursor AI Role-Specific Rules

This directory contains role-specific rule sets for constraining AI development in Cursor when working on specific tasks. These rules help ensure that AI assistance remains focused on the appropriate scope of work and follows best practices for each specialized area.

## Available Role-Specific Rules

| Role | Description | File |
|------|-------------|------|
| **Dashboard Developer** | Rules for modifying dashboard components and visualizations | [cursor-ai-rules-dashboard-developer.md](./cursor-ai-rules-dashboard-developer.md) |
| **API Developer** | Rules for creating and modifying API endpoints | [cursor-ai-rules-api-developer.md](./cursor-ai-rules-api-developer.md) |
| **Authentication & Security Specialist** | Rules for implementing and auditing security features | [cursor-ai-rules-auth-security-specialist.md](./cursor-ai-rules-auth-security-specialist.md) |
| **Database & Schema Developer** | Rules for designing and modifying database schemas | [cursor-ai-rules-database-schema-developer.md](./cursor-ai-rules-database-schema-developer.md) |
| **UI Component Developer** | Rules for creating and modifying UI components | [cursor-ai-rules-ui-component-developer.md](./cursor-ai-rules-ui-component-developer.md) |

## How to Use These Rules

1. **Identify the appropriate role** for your current development task
2. **Copy the relevant rules file** into your project workspace
3. **Reference these rules in your prompt** to Cursor AI to constrain its development focus

Example prompt:

```
I need help modifying the dashboard to add a new chart component. 
Please follow the rules in the cursor-ai-rules-dashboard-developer.md file.
The new chart should display...
```

## Common Structure

Each role-specific rules file follows a common structure:

1. **Role Context** - Defines the specific responsibility and focus area
2. **Core Constraints** - Specific limitations on what can be modified
3. **Workflow Guidelines** - Process recommendations for the specific role
4. **Security/Performance Considerations** - Role-specific concerns
5. **Branch Management** - How to manage code changes within the AI workflow
6. **Communication Protocol** - How to request clarification or suggest improvements

## Creating Custom Role Rules

To create custom role-specific rules for your project:

1. Copy one of the existing files as a template
2. Modify the rules to match your specific role requirements
3. Add the new file to this index

## Integration with Repository Workflow

These role-specific rules complement the overall repository workflow defined in the main README.md. The branch structure and promotion process should be followed regardless of the specific role. 