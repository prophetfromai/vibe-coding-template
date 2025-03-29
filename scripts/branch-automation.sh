#!/bin/bash

set -e

# Check if feature name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <feature-name>"
  exit 1
fi

FEATURE_NAME=$1
CURRENT_BRANCH=$(git branch --show-current)
BASE_BRANCH="main"

echo "🚀 Automating branch workflow for feature: $FEATURE_NAME"

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

# Step 1: Create ai-gen branch if it doesn't exist
AI_GEN_BRANCH="ai-gen/$FEATURE_NAME"
if branch_exists "$AI_GEN_BRANCH"; then
  echo "🔍 Branch $AI_GEN_BRANCH already exists. Checking out..."
  git checkout "$AI_GEN_BRANCH"
else
  echo "🌱 Creating new ai-gen branch: $AI_GEN_BRANCH"
  git checkout -b "$AI_GEN_BRANCH"
  
  # Initial commit on the new branch
  echo "📝 Creating initial commit on $AI_GEN_BRANCH"
  echo "# AI Generated Feature: $FEATURE_NAME" > "docs/features/$FEATURE_NAME.md"
  mkdir -p "docs/features" 2>/dev/null || true
  git add "docs/features/$FEATURE_NAME.md"
  git commit -m "feat: initialize $FEATURE_NAME feature structure"
  
  # Push new branch to remote
  echo "⬆️  Pushing $AI_GEN_BRANCH to remote..."
  git push -u origin "$AI_GEN_BRANCH"
  
  echo "✅ AI-Gen branch created and pushed. Now you can start working with the AI assistant."
  echo "ℹ️  When ready to promote to review stage, run: $0 $FEATURE_NAME promote-to-review"
  exit 0
fi

# Handle promotion to ai-review
if [ "$2" = "promote-to-review" ]; then
  # Make sure we're on the ai-gen branch
  if [ "$(git branch --show-current)" != "$AI_GEN_BRANCH" ]; then
    echo "⚠️  You must be on the $AI_GEN_BRANCH branch to promote it."
    exit 1
  fi
  
  # Create ai-review branch
  AI_REVIEW_BRANCH="ai-review/$FEATURE_NAME"
  
  if branch_exists "$AI_REVIEW_BRANCH"; then
    echo "⚠️  Branch $AI_REVIEW_BRANCH already exists."
    
    # Ask if user wants to force update
    read -p "Do you want to force update the existing review branch? (y/n): " FORCE_UPDATE
    if [ "$FORCE_UPDATE" != "y" ]; then
      echo "❌ Promotion aborted."
      exit 1
    fi
    
    echo "🔄 Force updating $AI_REVIEW_BRANCH with changes from $AI_GEN_BRANCH..."
    git checkout "$AI_REVIEW_BRANCH"
    git merge -X theirs "$AI_GEN_BRANCH" -m "feat: promote $FEATURE_NAME to review stage"
  else
    echo "🌿 Creating ai-review branch: $AI_REVIEW_BRANCH"
    git checkout -b "$AI_REVIEW_BRANCH"
  fi
  
  # Push to remote
  git push -u origin "$AI_REVIEW_BRANCH"
  
  echo "✅ Promoted to AI-Review stage."
  echo "ℹ️  When ready to promote to production stage, run: $0 $FEATURE_NAME promote-to-prod"
  exit 0
fi

# Handle promotion to ai-prod
if [ "$2" = "promote-to-prod" ]; then
  AI_REVIEW_BRANCH="ai-review/$FEATURE_NAME"
  
  # Make sure ai-review branch exists
  if ! branch_exists "$AI_REVIEW_BRANCH"; then
    echo "❌ The ai-review branch ($AI_REVIEW_BRANCH) does not exist."
    exit 1
  fi
  
  # Make sure we're on the ai-review branch
  if [ "$(git branch --show-current)" != "$AI_REVIEW_BRANCH" ]; then
    echo "⚠️  Switching to $AI_REVIEW_BRANCH branch..."
    git checkout "$AI_REVIEW_BRANCH"
  fi
  
  # Create ai-prod branch
  AI_PROD_BRANCH="ai-prod/$FEATURE_NAME"
  
  if branch_exists "$AI_PROD_BRANCH"; then
    echo "⚠️  Branch $AI_PROD_BRANCH already exists."
    
    # Ask if user wants to force update
    read -p "Do you want to force update the existing production branch? (y/n): " FORCE_UPDATE
    if [ "$FORCE_UPDATE" != "y" ]; then
      echo "❌ Promotion aborted."
      exit 1
    fi
    
    echo "🔄 Force updating $AI_PROD_BRANCH with changes from $AI_REVIEW_BRANCH..."
    git checkout "$AI_PROD_BRANCH"
    git merge -X theirs "$AI_REVIEW_BRANCH" -m "feat: promote $FEATURE_NAME to production stage"
  else
    echo "🌿 Creating ai-prod branch: $AI_PROD_BRANCH"
    git checkout -b "$AI_PROD_BRANCH"
  fi
  
  # Push to remote
  git push -u origin "$AI_PROD_BRANCH"
  
  echo "✅ Promoted to AI-Prod stage."
  echo "ℹ️  To create a pull request to main, visit the repository on GitHub."
  exit 0
fi

echo "ℹ️  You are now on the $AI_GEN_BRANCH branch."
echo "ℹ️  Available commands:"
echo "    - $0 $FEATURE_NAME promote-to-review"
echo "    - $0 $FEATURE_NAME promote-to-prod" 