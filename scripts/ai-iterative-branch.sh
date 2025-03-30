#!/bin/bash

set -e

# Check if feature name and number of iterations are provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <feature-name> <number-of-iterations> [requirements-file]"
  echo "Example: $0 update-auth 3 docs/code-requirements/security-rules.md"
  exit 1
fi

FEATURE_NAME=$1
ITERATIONS=$2
REQUIREMENTS_FILE=$3
CURRENT_BRANCH=$(git branch --show-current)
BASE_BRANCH="main"

echo "🚀 Setting up iterative AI code generation for feature: $FEATURE_NAME with $ITERATIONS iterations"

# Function to check if a branch exists
branch_exists() {
  git rev-parse --verify "$1" >/dev/null 2>&1
}

# Ensure we're on main before starting
if [ "$CURRENT_BRANCH" != "$BASE_BRANCH" ]; then
  echo "⚠️  You are not on $BASE_BRANCH branch. Switching to $BASE_BRANCH..."
  git checkout $BASE_BRANCH
fi

# Pull latest changes from base branch
echo "📥 Pulling latest changes from $BASE_BRANCH..."
git pull origin $BASE_BRANCH

# Step 1: Create initial ai-gen branch
AI_GEN_BRANCH="ai-gen/$FEATURE_NAME/iteration-0"
if branch_exists "$AI_GEN_BRANCH"; then
  echo "⚠️  Branch $AI_GEN_BRANCH already exists."
  read -p "Do you want to overwrite the existing branch? (y/n): " OVERWRITE
  if [ "$OVERWRITE" != "y" ]; then
    echo "❌ Process aborted."
    exit 1
  fi
  git branch -D "$AI_GEN_BRANCH"
fi

echo "🌱 Creating initial AI generation branch: $AI_GEN_BRANCH"
git checkout -b "$AI_GEN_BRANCH"

# Create requirements directory and documentation if provided
mkdir -p "docs/features/$FEATURE_NAME" 2>/dev/null || true

# Initialize feature documentation
echo "# AI Generated Feature: $FEATURE_NAME" > "docs/features/$FEATURE_NAME/README.md"
echo "" >> "docs/features/$FEATURE_NAME/README.md"
echo "## Overview" >> "docs/features/$FEATURE_NAME/README.md"
echo "This feature was developed through an iterative AI code generation process." >> "docs/features/$FEATURE_NAME/README.md"
echo "" >> "docs/features/$FEATURE_NAME/README.md"
echo "## Iterations" >> "docs/features/$FEATURE_NAME/README.md"
echo "Total planned iterations: $ITERATIONS" >> "docs/features/$FEATURE_NAME/README.md"

# If requirements file is provided, copy it
if [ ! -z "$REQUIREMENTS_FILE" ] && [ -f "$REQUIREMENTS_FILE" ]; then
  echo "📋 Copying requirements file to feature documentation..."
  cp "$REQUIREMENTS_FILE" "docs/features/$FEATURE_NAME/requirements.md"
  echo "" >> "docs/features/$FEATURE_NAME/README.md"
  echo "## Requirements" >> "docs/features/$FEATURE_NAME/README.md"
  echo "See [requirements.md](requirements.md) for detailed requirements." >> "docs/features/$FEATURE_NAME/README.md"
fi

# Create iteration tracking file
echo "# Iteration Progress" > "docs/features/$FEATURE_NAME/iterations.md"
echo "" >> "docs/features/$FEATURE_NAME/iterations.md"
echo "## Iteration 0 (Initial)" >> "docs/features/$FEATURE_NAME/iterations.md"
echo "- Status: Initialized" >> "docs/features/$FEATURE_NAME/iterations.md"
echo "- Date: $(date)" >> "docs/features/$FEATURE_NAME/iterations.md"
echo "- Branch: \`$AI_GEN_BRANCH\`" >> "docs/features/$FEATURE_NAME/iterations.md"
echo "" >> "docs/features/$FEATURE_NAME/iterations.md"

# Add and commit all the documentation
git add "docs/features/$FEATURE_NAME/"
git commit -m "feat: initialize $FEATURE_NAME feature structure and documentation"

# Push initial branch to remote
git push -u origin "$AI_GEN_BRANCH"

echo "✅ Initial AI generation branch created: $AI_GEN_BRANCH"
echo ""
echo "🔄 Next steps:"
echo "1. Collaborate with the AI assistant to implement the initial version"
echo "2. When ready, run: $0 $FEATURE_NAME $ITERATIONS iterate 1"
echo ""
echo "To continue with an iteration, use:"
echo "$0 $FEATURE_NAME $ITERATIONS iterate <iteration-number>"

# Handle iteration creation
if [ "$3" = "iterate" ] && [ ! -z "$4" ]; then
  ITERATION_NUM=$4
  
  # Check if iteration number is valid
  if [ $ITERATION_NUM -lt 1 ] || [ $ITERATION_NUM -gt $ITERATIONS ]; then
    echo "❌ Invalid iteration number. Must be between 1 and $ITERATIONS."
    exit 1
  fi
  
  PREV_ITERATION=$((ITERATION_NUM - 1))
  PREV_BRANCH="ai-gen/$FEATURE_NAME/iteration-$PREV_ITERATION"
  NEW_BRANCH="ai-gen/$FEATURE_NAME/iteration-$ITERATION_NUM"
  
  # Make sure previous iteration branch exists
  if ! branch_exists "$PREV_BRANCH"; then
    echo "❌ The previous iteration branch ($PREV_BRANCH) does not exist."
    exit 1
  fi
  
  # Make sure we're on the previous iteration branch
  if [ "$(git branch --show-current)" != "$PREV_BRANCH" ]; then
    echo "⚠️  Switching to $PREV_BRANCH branch..."
    git checkout "$PREV_BRANCH"
  fi
  
  # Create new iteration branch
  if branch_exists "$NEW_BRANCH"; then
    echo "⚠️  Branch $NEW_BRANCH already exists."
    read -p "Do you want to overwrite the existing branch? (y/n): " OVERWRITE
    if [ "$OVERWRITE" != "y" ]; then
      echo "❌ Iteration creation aborted."
      exit 1
    fi
    git branch -D "$NEW_BRANCH"
  fi
  
  echo "🌿 Creating iteration branch: $NEW_BRANCH"
  git checkout -b "$NEW_BRANCH"
  
  # Update iteration tracking file
  echo "## Iteration $ITERATION_NUM" >> "docs/features/$FEATURE_NAME/iterations.md"
  echo "- Status: In Progress" >> "docs/features/$FEATURE_NAME/iterations.md"
  echo "- Date: $(date)" >> "docs/features/$FEATURE_NAME/iterations.md"
  echo "- Branch: \`$NEW_BRANCH\`" >> "docs/features/$FEATURE_NAME/iterations.md"
  echo "- Based on: \`$PREV_BRANCH\`" >> "docs/features/$FEATURE_NAME/iterations.md"
  echo "" >> "docs/features/$FEATURE_NAME/iterations.md"
  
  # Add and commit the updated tracking
  git add "docs/features/$FEATURE_NAME/iterations.md"
  git commit -m "feat: start iteration $ITERATION_NUM for $FEATURE_NAME"
  
  # Push new branch to remote
  git push -u origin "$NEW_BRANCH"
  
  echo "✅ Iteration $ITERATION_NUM branch created: $NEW_BRANCH"
  
  if [ $ITERATION_NUM -eq $ITERATIONS ]; then
    echo "🎉 This is the final planned iteration. After completing this iteration, run:"
    echo "$0 $FEATURE_NAME $ITERATIONS finalize"
  else
    echo "🔄 After completing this iteration, run:"
    echo "$0 $FEATURE_NAME $ITERATIONS iterate $((ITERATION_NUM + 1))"
  fi
  
  exit 0
fi

# Handle finalization
if [ "$3" = "finalize" ]; then
  FINAL_BRANCH="ai-gen/$FEATURE_NAME/iteration-$ITERATIONS"
  REVIEW_BRANCH="ai-review/$FEATURE_NAME"
  
  # Make sure final iteration branch exists
  if ! branch_exists "$FINAL_BRANCH"; then
    echo "❌ The final iteration branch ($FINAL_BRANCH) does not exist."
    exit 1
  fi
  
  # Make sure we're on the final iteration branch
  if [ "$(git branch --show-current)" != "$FINAL_BRANCH" ]; then
    echo "⚠️  Switching to $FINAL_BRANCH branch..."
    git checkout "$FINAL_BRANCH"
  fi
  
  # Create review branch
  if branch_exists "$REVIEW_BRANCH"; then
    echo "⚠️  Branch $REVIEW_BRANCH already exists."
    read -p "Do you want to overwrite the existing review branch? (y/n): " OVERWRITE
    if [ "$OVERWRITE" != "y" ]; then
      echo "❌ Finalization aborted."
      exit 1
    fi
    git branch -D "$REVIEW_BRANCH"
  fi
  
  echo "🌿 Creating review branch: $REVIEW_BRANCH"
  git checkout -b "$REVIEW_BRANCH"
  
  # Update feature documentation
  echo "## Final Review" >> "docs/features/$FEATURE_NAME/README.md"
  echo "After $ITERATIONS iterations, this feature is now ready for human review." >> "docs/features/$FEATURE_NAME/README.md"
  echo "- Date: $(date)" >> "docs/features/$FEATURE_NAME/README.md"
  echo "" >> "docs/features/$FEATURE_NAME/README.md"
  
  # Update iteration tracking file
  echo "## Final Review" >> "docs/features/$FEATURE_NAME/iterations.md"
  echo "- Status: Ready for Human Review" >> "docs/features/$FEATURE_NAME/iterations.md"
  echo "- Date: $(date)" >> "docs/features/$FEATURE_NAME/iterations.md"
  echo "- Branch: \`$REVIEW_BRANCH\`" >> "docs/features/$FEATURE_NAME/iterations.md"
  
  # Add and commit the updated documentation
  git add "docs/features/$FEATURE_NAME/"
  git commit -m "feat: finalize $FEATURE_NAME after $ITERATIONS iterations"
  
  # Push review branch to remote
  git push -u origin "$REVIEW_BRANCH"
  
  echo "✅ Feature finalized and moved to review branch: $REVIEW_BRANCH"
  echo ""
  echo "Next steps:"
  echo "1. Conduct human review of the code"
  echo "2. When approved, use the original branch-automation.sh script to promote to production:"
  echo "   ./scripts/branch-automation.sh $FEATURE_NAME promote-to-prod"
  
  exit 0
fi 