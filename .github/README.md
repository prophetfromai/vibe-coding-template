# GitHub Workflows for AI-Generated Code

This directory contains GitHub Actions workflows and configuration files for CI/CD processes specifically designed for AI-generated code. This README provides guidelines for AI assistants regarding GitHub automation.

## Workflow Structure

```
.github/
  ├── workflows/                          # GitHub Actions workflows
  │   ├── ai-gen-validation.yml           # Validation workflow for ai-gen branches
  │   ├── ai-review-checks.yml            # Comprehensive checks for ai-review branches
  │   ├── ai-prod-deployment.yml          # Deployment workflow for ai-prod branches
  │   └── security-scans.yml              # Security scanning workflow
  ├── CODEOWNERS                          # Code ownership definitions
  ├── pull_request_template.md            # Pull request template
  └── ISSUE_TEMPLATE/                     # Issue templates
      ├── ai_feature_request.md           # Template for AI feature requests
      └── ai_bug_report.md                # Template for AI-generated code bugs
```

## Branch Protection Rules

### 1. `ai-gen/*` Branches

Branch protection rules for initial AI-generated code:

- No direct push access (create via PR only)
- Required status checks:
  - Linting
  - Basic security scan
  - Type checking
- Pull request review:
  - At least 1 reviewer required
  - Stale review dismissal

### 2. `ai-review/*` Branches

Branch protection rules for reviewed AI code:

- No direct push access
- Required status checks:
  - All tests passing
  - Comprehensive security scan
  - Performance benchmarks
  - Code coverage thresholds
- Pull request review:
  - At least 2 reviewers required
  - Code owner review required
  - Stale review dismissal

### 3. `ai-prod/*` Branches

Branch protection rules for production-ready AI code:

- No direct push access
- Required status checks:
  - All tests passing
  - Comprehensive security scan
  - Performance benchmarks
  - Code coverage thresholds
  - Integration tests
- Pull request review:
  - At least 2 reviewers required
  - Code owner review required
  - Senior developer approval required
  - Stale review dismissal

## GitHub Actions Workflows

### 1. AI-Gen Validation Workflow

```yaml
# ai-gen-validation.yml
name: AI-Gen Validation

on:
  pull_request:
    branches:
      - 'ai-gen/**'
  push:
    branches:
      - 'ai-gen/**'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      - name: Install dependencies
        run: npm ci
      - name: Lint
        run: npm run lint
      - name: Type check
        run: npm run type-check
      - name: Unit tests
        run: npm run test:unit
      - name: Basic security scan
        uses: github/codeql-action/analyze@v2
        with:
          languages: javascript, typescript
          queries: security-minimal
      - name: Report
        if: always()
        run: |
          echo "## Validation Summary" >> $GITHUB_STEP_SUMMARY
          echo "- Linting: ${{ job.steps.lint.outcome }}" >> $GITHUB_STEP_SUMMARY
          echo "- Type Check: ${{ job.steps.type-check.outcome }}" >> $GITHUB_STEP_SUMMARY
          echo "- Unit Tests: ${{ job.steps.unit-tests.outcome }}" >> $GITHUB_STEP_SUMMARY
          echo "- Security Scan: ${{ job.steps.security-scan.outcome }}" >> $GITHUB_STEP_SUMMARY
```

### 2. AI-Review Checks Workflow

```yaml
# ai-review-checks.yml
name: AI-Review Comprehensive Checks

on:
  pull_request:
    branches:
      - 'ai-review/**'
  push:
    branches:
      - 'ai-review/**'

jobs:
  comprehensive-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      - name: Install dependencies
        run: npm ci
      - name: Lint
        run: npm run lint
      - name: Type check
        run: npm run type-check
      - name: Unit tests
        run: npm run test:unit
      - name: Integration tests
        run: npm run test:integration
      - name: Coverage report
        run: npm run test:coverage
      - name: Comprehensive security scan
        uses: github/codeql-action/analyze@v2
        with:
          languages: javascript, typescript
          queries: security-extended
      - name: Dependency audit
        run: npm audit --production
      - name: Performance benchmark
        run: npm run benchmark
      - name: Bundle size analysis
        uses: preactjs/compressed-size-action@v2
      - name: Documentation check
        run: npm run docs:check
```

### 3. AI-Prod Deployment Workflow

```yaml
# ai-prod-deployment.yml
name: AI-Prod Deployment

on:
  pull_request:
    branches:
      - main
    paths:
      - 'src/**'
  push:
    branches:
      - main
    paths:
      - 'src/**'

jobs:
  validate-and-build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      - name: Install dependencies
        run: npm ci
      - name: Comprehensive checks
        run: |
          npm run lint
          npm run type-check
          npm run test:unit
          npm run test:integration
          npm run test:e2e
      - name: Build
        run: npm run build
      - name: Upload build artifacts
        uses: actions/upload-artifact@v3
        with:
          name: build
          path: dist

  security-review:
    needs: validate-and-build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Security scan
        uses: github/codeql-action/analyze@v2
        with:
          languages: javascript, typescript
          queries: security-and-quality
      - name: SAST scan
        uses: some/sast-action@v1
      - name: Dependency scan
        run: npm audit --production --audit-level=moderate
      - name: License compliance
        uses: some/license-compliance-action@v1

  deploy-staging:
    needs: [validate-and-build, security-review]
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/checkout@v3
      - name: Download build artifacts
        uses: actions/download-artifact@v3
        with:
          name: build
          path: dist
      - name: Deploy to staging
        run: |
          # Deployment script
          echo "Deploying to staging environment"
      - name: Run smoke tests
        run: npm run test:smoke

  deploy-production:
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v3
      - name: Download build artifacts
        uses: actions/download-artifact@v3
        with:
          name: build
          path: dist
      - name: Deploy to production
        run: |
          # Deployment script
          echo "Deploying to production environment"
      - name: Verify deployment
        run: |
          # Verification script
          echo "Verifying production deployment"
```

## Pull Request Templates

### AI-Generated Code PR Template

```markdown
## AI-Generated Code Pull Request

### Description
[Describe the feature or change implemented by this AI-generated code]

### AI Generation Process
- **AI Assistant Used**: [Name of AI assistant]
- **Prompt Engineering**: [Brief description of prompts used]
- **Human Refinement**: [Description of human refinements made]

### Validation Checklist
- [ ] Code follows project conventions and style guidelines
- [ ] All specified requirements are implemented
- [ ] Edge cases are handled appropriately
- [ ] Error handling is comprehensive
- [ ] Security best practices are followed
- [ ] Performance considerations are addressed
- [ ] Tests are included and passing
- [ ] Documentation is complete and accurate

### Security Considerations
[Describe any security considerations and how they were addressed]

### Testing Approach
[Describe the testing approach and test coverage]

### Additional Notes
[Any additional information that would be helpful for reviewers]
```

## Issue Templates

### AI Feature Request Template

```markdown
## AI Feature Request

### Feature Description
[Provide a clear and concise description of the feature]

### Use Cases
[Describe the use cases or user stories for this feature]

### Technical Requirements
[List specific technical requirements and constraints]

### Implementation Suggestions
[Provide any suggestions for implementation approach]

### AI Collaboration Approach
[Describe how AI should be involved in implementing this feature]
- [ ] Task-Specific AI Assistance
- [ ] Pair Programming with AI
- [ ] AI-Driven Exploration

### Security and Performance Considerations
[Note any security or performance considerations]

### Additional Context
[Add any other context or screenshots about the feature request]
```

## Automation Guidelines

### 1. Automated Code Review

Configure automated code review for AI-generated code:

- Style and formatting checks
- Code quality metrics
- Documentation coverage
- Security vulnerability detection
- Performance impact analysis

### 2. Status Checks

Require these status checks before merging:

- All tests passing
- Security scan passing
- Code coverage thresholds met
- Performance benchmarks within acceptable ranges
- Documentation completeness check

### 3. PR Labeling Automation

Automatically label PRs based on content:

- `ai-generated`: Code primarily generated by AI
- `human-refined`: AI-generated code with significant human refinement
- `security-review-needed`: Contains changes to security-sensitive areas
- `performance-critical`: Contains changes to performance-critical code
- `needs-docs`: Missing or incomplete documentation

## Security Workflow

### Continuous Security Scanning

```yaml
# security-scans.yml
name: Security Scanning

on:
  schedule:
    - cron: '0 2 * * *'  # Run daily at 2 AM
  workflow_dispatch:     # Allow manual triggering

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: CodeQL Analysis
        uses: github/codeql-action/analyze@v2
        with:
          languages: javascript, typescript
          queries: security-and-quality
      - name: SAST Scan
        uses: some/sast-action@v1
      - name: Dependency Scan
        run: npm audit --production
      - name: Secret Scanning
        uses: some/secret-scanning-action@v1
      - name: Generate Security Report
        run: |
          echo "# Security Scan Results" > security-report.md
          # Add scan results to report
      - name: Upload Security Report
        uses: actions/upload-artifact@v3
        with:
          name: security-report
          path: security-report.md
```

## Deployment Strategy

### Progressive Deployment for AI-Generated Code

- Feature flags for all new AI-generated features
- Canary deployments for initial rollout
- Monitoring and automatic rollback triggers
- A/B testing for complex features
- Progressive feature exposure based on reliability metrics 