# AI Code Assistant Template

This repository outlines an opinionated approach for safely integrating AI-generated code into production applications. It defines a structured workflow, safety mechanisms, and quality standards for working with AI assistants.

## Repository Structure

```
.
├── README.md                  # Project overview
├── README-CICD.md             # CI/CD pipeline and quality assurance
├── src/                       # Application source code
│   ├── README.md              # Source code organization
│   ├── components/            # UI components
│   │   └── README.md          # Component design patterns
│   ├── services/              # Business logic and data access
│   │   └── README.md          # Service architecture patterns
│   ├── utils/                 # Shared utilities
│   │   └── README.md          # Utility conventions
│   └── config/                # Configuration
│       └── README.md          # Configuration management
├── tests/                     # Testing infrastructure
│   └── README.md              # Testing guidelines
├── docs/                      # Documentation
│   ├── README.md              # Documentation overview
│   ├── security/              # Security guidelines
│   │   └── README.md          # Security protocols
│   └── workflows/             # Workflow documentation
│       └── README.md          # AI/human collaboration workflows
└── .github/                   # GitHub configurations
    └── README.md              # GitHub automation guidelines
```

## Core Principles

1. **Branch Isolation** - AI-generated code exists only in dedicated branches
2. **Progressive Validation** - Multiple verification stages before production
3. **Explicit Intent** - Clear specifications communicated to AI assistants
4. **Defensible Design** - Architectural patterns that limit scope and risk
5. **Continuous Verification** - Automated checks for security and quality

## Getting Started

1. Read the `README-CICD.md` file to understand the workflow
2. Explore the `docs/workflows/README.md` for collaboration patterns
3. Use the section-specific READMEs to guide AI code generation

## Technology Stack

This template can be adapted for various technology stacks while maintaining the core safety principles.
