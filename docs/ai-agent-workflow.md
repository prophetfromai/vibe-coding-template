# AI Code Generation Agent Workflow

> **Important**: This document provides essential guidance for AI code generation agents. You MUST follow these instructions to ensure compliance with project standards and security protocols.

## Required Reading Sequence

As an AI code generation agent, you must read and understand the repository documentation in this specific order:

```mermaid
graph TD
    A[1. Top-level README.md] -->|Read First| B[2. docs/README.md]
    B -->|Then Read| C[3. docs/cursor-ai-rules-index.md]
    C -->|Finally Read| D[4. Role-specific Rules File]
    D --> E[Begin Code Generation]
    
    style A fill:#d0f0c0,stroke:#333,stroke-width:2px
    style D fill:#c0d0f0,stroke:#333,stroke-width:2px
    style E fill:#f0c0c0,stroke:#333,stroke-width:2px
```

## Branch Structure Compliance

All AI-generated code must follow this branch structure:

```mermaid
graph LR
    A[AI-Generated Code] --> B[ai-gen/domain-feature]
    B -->|Human Review| C[ai-review/domain-feature]
    C -->|Final Approval| D[ai-prod/domain-feature]
    D -->|Integration| E[main/production]
    
    style A fill:#f9f9f9,stroke:#333,stroke-width:1px
    style B fill:#ffdddd,stroke:#333,stroke-width:2px
    style C fill:#ddffdd,stroke:#333,stroke-width:2px
    style D fill:#ddddff,stroke:#333,stroke-width:2px
    style E fill:#ffffdd,stroke:#333,stroke-width:2px
```

### Common Pitfall: Incorrect Branch Usage

❌ **INCORRECT WORKFLOW**:

```mermaid
graph LR
    A[AI-Generated Code] -->|WRONG!| B[main/production]
    
    style A fill:#f9f9f9,stroke:#333,stroke-width:1px
    style B fill:#ff9999,stroke:#red,stroke-width:3px
```

✅ **CORRECT WORKFLOW**:

```mermaid
graph LR
    A[AI-Generated Code] --> B[ai-gen/domain-feature]
    
    style A fill:#f9f9f9,stroke:#333,stroke-width:1px
    style B fill:#99ff99,stroke:#green,stroke-width:2px
```

## Role Context Adherence

You must:

1. Identify which role-specific rules apply to the current task
2. Strictly adhere to the scope limitations defined in the role context
3. Never modify files outside your authorized scope
4. Follow all architectural and design patterns specified in the documentation

```mermaid
graph TD
    A[Task Request] --> B{Determine Role}
    B --> C[UI Developer]
    B --> D[API Developer]
    B --> E[Database Developer]
    B --> F[Security Specialist]
    B --> G[Dashboard Developer]
    
    C --> H{Check File Scope}
    D --> H
    E --> H
    F --> H
    G --> H
    
    H -->|In Scope| I[Proceed with Changes]
    H -->|Out of Scope| J[Do Not Modify]
    
    style H fill:#ffffcc,stroke:#333,stroke-width:2px
    style I fill:#ccffcc,stroke:#333,stroke-width:2px
    style J fill:#ffcccc,stroke:#333,stroke-width:2px
```

### Common Pitfall: Scope Violation

```mermaid
graph TD
    A[UI Developer Role] -->|Has Access To| B[UI Components]
    A -->|Has Access To| C[CSS/Styling]
    A -->|Has Access To| D[UI Tests]
    
    A -->|WRONG! No Access| E[Database Schema]
    A -->|WRONG! No Access| F[Authentication Logic]
    A -->|WRONG! No Access| G[API Endpoints]
    
    style A fill:#d0f0c0,stroke:#333,stroke-width:2px
    style B fill:#c0d0f0,stroke:#333,stroke-width:1px
    style C fill:#c0d0f0,stroke:#333,stroke-width:1px
    style D fill:#c0d0f0,stroke:#333,stroke-width:1px
    style E fill:#ffcccc,stroke:red,stroke-width:3px
    style F fill:#ffcccc,stroke:red,stroke-width:3px
    style G fill:#ffcccc,stroke:red,stroke-width:3px
```

## Decision Flow for Code Generation

```mermaid
flowchart TD
    A[Receive Task] --> B{Does Task Match Role?}
    B -->|Yes| C{Files In Scope?}
    B -->|No| D[Request Clarification]
    
    C -->|Yes| E{Follow Architectural Pattern?}
    C -->|No| F[Request Permission]
    
    E -->|Yes| G[Generate Code]
    E -->|No| H[Suggest Alternative]
    
    G --> I{Test Requirements?}
    I -->|Yes| J[Include Tests]
    I -->|No| K[Generate Code Only]
    
    style D fill:#ffdddd,stroke:#333,stroke-width:2px
    style F fill:#ffdddd,stroke:#333,stroke-width:2px
    style H fill:#ffffdd,stroke:#333,stroke-width:2px
    style G fill:#ddffdd,stroke:#333,stroke-width:2px
```

## Quality Standards

All generated code must:

1. Follow the project's coding standards and conventions
2. Include appropriate tests as specified in the role-specific rules
3. Address security considerations relevant to your role
4. Optimize for performance according to project guidelines

## Communication Protocol

When working with developers:

1. Always clarify scope boundaries before generating code
2. Request explicit confirmation when suggesting architectural changes
3. Clearly indicate which role-specific rules you are following
4. Report any potential conflicts between requirements and constraints

```mermaid
sequenceDiagram
    participant D as Developer
    participant AI as AI Assistant
    participant C as Codebase
    
    D->>AI: Request Feature
    AI->>C: Read Documentation
    AI->>AI: Identify Role Context
    AI->>D: Confirm Scope Understanding
    D->>AI: Confirm or Clarify
    AI->>C: Generate Code in ai-gen/ Branch
    AI->>D: Present Code for Review
    D->>C: Review and Promote to ai-review/
    D->>C: Integrate to ai-prod/ after Testing
```

## Example Workflow

### 1. Initial Assessment

```
I'll help with your task. First, I need to understand the context:

1. I'll read the README.md to understand the repository structure
2. I'll check the role-specific rules that apply to this task
3. I'll identify the correct branch structure to use
```

### 2. Repository Understanding

```
Based on the README.md, I understand that:
- This repository follows [specific architecture]
- The branch structure requires AI-generated code to start in the ai-gen/ branch
- I should focus on [specific domain] based on your request
```

### 3. Role Identification

```
For this task, I'll follow the rules in cursor-ai-rules-[role].md which means:
- I can modify [allowed files/directories]
- I should not modify [prohibited files/directories]
- I need to follow [specific design patterns]
```

### 4. Code Generation

```
I'll now generate code that:
- Adheres to the repository's architectural patterns
- Follows the role-specific constraints
- Includes necessary tests
- Addresses security considerations
```

## Common Pitfalls and Solutions

### 1. Mixing Responsibilities

```mermaid
graph TD
    A[Task: Update User Profile UI] --> B{Responsibility Assessment}
    B -->|Correct Approach| C[UI Developer: Update User Component]
    B -->|WRONG Approach| D[UI Developer: Also Modify User API]
    B -->|WRONG Approach| E[UI Developer: Also Change Database Schema]
    
    C --> F[Safe Implementation]
    D --> G[Role Violation!]
    E --> H[Role Violation!]
    
    style C fill:#ccffcc,stroke:#333,stroke-width:2px
    style D fill:#ffcccc,stroke:red,stroke-width:2px
    style E fill:#ffcccc,stroke:red,stroke-width:2px
    style F fill:#ccffcc,stroke:#333,stroke-width:2px
    style G fill:#ffcccc,stroke:red,stroke-width:2px
    style H fill:#ffcccc,stroke:red,stroke-width:2px
```

### 2. Bypassing Branch Structure

```mermaid
graph TD
    A[Code Change Request] --> B{Branch Selection}
    B -->|Correct| C[Create/Use ai-gen/branch]
    B -->|WRONG!| D[Directly Modify main]
    B -->|WRONG!| E[Create Non-ai Branch]
    
    C --> F[Follows Workflow]
    D --> G[Violates Process!]
    E --> H[Confuses Process!]
    
    style C fill:#ccffcc,stroke:#333,stroke-width:2px
    style D fill:#ffcccc,stroke:red,stroke-width:2px
    style E fill:#ffcccc,stroke:red,stroke-width:2px
    style F fill:#ccffcc,stroke:#333,stroke-width:2px
    style G fill:#ffcccc,stroke:red,stroke-width:2px
    style H fill:#ffcccc,stroke:red,stroke-width:2px
```

## Violation Consequences

Failure to follow this workflow may result in:

1. Generated code being rejected
2. Additional review cycles
3. Potential security or quality issues
4. Undermining trust in AI assistance

Always prioritize strict adherence to project guidelines over speed or feature completeness. 