#!/bin/bash

set -e

echo "🚀 Starting repository setup for AI Code Assistant Template"

# Ensure directories exist
mkdir -p docs/features
mkdir -p src/{components,services,utils,config}
mkdir -p tests/{unit,integration,e2e}
mkdir -p .github/{workflows,ISSUE_TEMPLATE}

# Make scripts executable
chmod +x scripts/branch-automation.sh
chmod +x scripts/setup-repo.sh

# Check if git is initialized
if [ ! -d .git ]; then
  echo "📥 Initializing git repository..."
  git init
fi

# Setup git hooks
if [ ! -d .git/hooks ]; then
  mkdir -p .git/hooks
fi

echo "🔧 Creating git hooks..."

# Create pre-commit hook
cat > .git/hooks/pre-commit << 'EOL'
#!/bin/bash

# Check branch naming convention
BRANCH_NAME=$(git symbolic-ref --short HEAD)

if [[ ! $BRANCH_NAME =~ ^(ai-gen|ai-review|ai-prod)/ && $BRANCH_NAME != "main" ]]; then
  echo "❌ Error: Branch name must follow convention: ai-gen/*, ai-review/*, ai-prod/*, or main"
  exit 1
fi

# Run basic linting if available
if command -v npm &> /dev/null && [ -f "package.json" ]; then
  if grep -q "\"lint\"" package.json; then
    echo "🔍 Running linting checks..."
    npm run lint
  fi
fi

exit 0
EOL
chmod +x .git/hooks/pre-commit

# Create commit-msg hook
cat > .git/hooks/commit-msg << 'EOL'
#!/bin/bash

COMMIT_MSG_FILE=$1
COMMIT_MSG=$(cat $COMMIT_MSG_FILE)

# Check commit message format (feat|fix|docs|style|refactor|test|chore)
if ! [[ $COMMIT_MSG =~ ^(feat|fix|docs|style|refactor|test|chore)(\([a-z0-9-]+\))?: [A-Z] ]]; then
  echo "❌ Error: Commit message must follow format: type(scope): Message"
  echo "   Example: feat(auth): Add password reset functionality"
  echo "   Valid types: feat, fix, docs, style, refactor, test, chore"
  exit 1
fi

exit 0
EOL
chmod +x .git/hooks/commit-msg

# Set up initial git config
git config --local core.autocrlf input
git config --local pull.rebase true

# Check if package.json exists, create if not
if [ ! -f package.json ]; then
  echo "📝 Creating package.json..."
  cat > package.json << 'EOL'
{
  "name": "ai-code-assistant-template",
  "version": "1.0.0",
  "description": "Opinionated approach for safely integrating AI-generated code",
  "main": "index.js",
  "scripts": {
    "lint": "echo 'No linting configured yet'",
    "test:unit": "echo 'No unit tests configured yet'",
    "test:integration": "echo 'No integration tests configured yet'",
    "test:e2e": "echo 'No e2e tests configured yet'",
    "security:basic": "echo 'No basic security scan configured yet'",
    "security:full": "echo 'No full security scan configured yet'"
  },
  "keywords": [
    "ai",
    "template",
    "code",
    "assistant"
  ],
  "author": "",
  "license": "MIT"
}
EOL
fi

# Create initial .gitignore if it doesn't exist
if [ ! -f .gitignore ]; then
  echo "📝 Creating .gitignore..."
  cat > .gitignore << 'EOL'
# Dependencies
node_modules/
.pnp/
.pnp.js

# Testing
coverage/
.nyc_output/

# Build outputs
dist/
build/
out/
.next/

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Logs
logs/
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# IDE and editors
.idea/
.vscode/
*.swp
*.swo
.DS_Store
EOL
fi

# Initialize basic README files in each directory
for dir in src/{components,services,utils,config} tests/{unit,integration,e2e}; do
  if [ ! -f "$dir/README.md" ]; then
    directory_name=$(basename $dir)
    echo "📝 Creating README.md in $dir..."
    cat > "$dir/README.md" << EOL
# $directory_name

This directory contains the $directory_name for the project.

## Guidelines

When working with AI assistants:

1. Clearly define requirements and constraints
2. Follow existing patterns and conventions
3. Apply appropriate tests for all new code
4. Document usage examples and edge cases
EOL
  fi
done

# Create staging branch structure if not exists
echo "🌿 Setting up branch structure..."

# Create main branch if not exists or not currently on it
if ! git show-ref --verify --quiet refs/heads/main; then
  # Check if we're in a fresh repo or if we're on master
  if git show-ref --verify --quiet refs/heads/master; then
    echo "⚠️  Repository has a 'master' branch. Creating 'main' branch..."
    git branch -m master main
  else
    echo "📝 Creating initial commit on main branch..."
    git add .
    git commit -m "chore: initial repository setup" || true
  fi
fi

# Make sure we're on main
git checkout main 2>/dev/null || true

# Create demo feature for branch automation
DEMO_FEATURE="demo-feature"
if ! git show-ref --verify --quiet refs/heads/ai-gen/$DEMO_FEATURE; then
  echo "🔍 Creating demo feature to demonstrate branch automation..."
  ./scripts/branch-automation.sh $DEMO_FEATURE
fi

echo "✅ Repository setup complete! Here's what to do next:"
echo ""
echo "1. Review the branch structure:"
echo "   - main branch: production code"
echo "   - ai-gen/$DEMO_FEATURE: example AI-generated feature branch"
echo ""
echo "2. Try the branch automation workflow:"
echo "   - ./scripts/branch-automation.sh $DEMO_FEATURE promote-to-review"
echo "   - ./scripts/branch-automation.sh $DEMO_FEATURE promote-to-prod"
echo ""
echo "3. Configure GitHub branch protection rules as described in .github/README.md"
echo ""
echo "Happy coding! 🎉" 