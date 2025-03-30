#!/bin/bash

set -e

# Check if feature name and iteration number are provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <feature-name> <iteration-number> [report-only]"
  echo "Example: $0 update-auth 1"
  exit 1
fi

FEATURE_NAME=$1
ITERATION_NUM=$2
REPORT_ONLY=${3:-"false"}
CURRENT_BRANCH=$(git branch --show-current)
EXPECTED_BRANCH="ai-gen/$FEATURE_NAME/iteration-$ITERATION_NUM"

echo "🔍 Starting AI code review for $FEATURE_NAME (Iteration $ITERATION_NUM)"

# Function to check if a branch exists
branch_exists() {
  git rev-parse --verify "$1" >/dev/null 2>&1
}

# Make sure we're on the correct branch
if [ "$CURRENT_BRANCH" != "$EXPECTED_BRANCH" ]; then
  if branch_exists "$EXPECTED_BRANCH"; then
    echo "⚠️  You are not on $EXPECTED_BRANCH branch. Switching to $EXPECTED_BRANCH..."
    git checkout "$EXPECTED_BRANCH"
  else
    echo "❌ The branch $EXPECTED_BRANCH does not exist."
    exit 1
  fi
fi

# Create directories if they don't exist
mkdir -p "docs/features/$FEATURE_NAME/reviews" 2>/dev/null || true

# Determine review focus based on iteration number
case $ITERATION_NUM in
  1)
    REVIEW_FOCUS="Core Functionality"
    ;;
  2)
    REVIEW_FOCUS="Code Quality & Style"
    ;;
  3)
    REVIEW_FOCUS="Security"
    ;;
  4)
    REVIEW_FOCUS="Performance Optimization"
    ;;
  5)
    REVIEW_FOCUS="Edge Cases & Resilience"
    ;;
  *)
    REVIEW_FOCUS="General Review"
    ;;
esac

# Get previous iteration branch name
PREV_ITERATION=$((ITERATION_NUM - 1))
PREV_BRANCH="ai-gen/$FEATURE_NAME/iteration-$PREV_ITERATION"

# Generate report file name
REPORT_FILE="docs/features/$FEATURE_NAME/reviews/iteration-${ITERATION_NUM}-review.md"
REPORT_TEMPLATE="docs/code-requirements/review-report-template.md"
REQUIREMENTS_FILE="docs/features/$FEATURE_NAME/requirements.md"

echo "📝 Generating AI review report template..."

# Check if template exists
if [ ! -f "$REPORT_TEMPLATE" ]; then
  echo "❌ Review report template not found at $REPORT_TEMPLATE."
  exit 1
fi

# Copy template and replace placeholders
cp "$REPORT_TEMPLATE" "$REPORT_FILE"

# Replace basic placeholders
sed -i.bak "s/\${FEATURE_NAME}/$FEATURE_NAME/g" "$REPORT_FILE"
sed -i.bak "s/\${ITERATION_NUMBER}/$ITERATION_NUM/g" "$REPORT_FILE"
sed -i.bak "s/\${DATE}/$(date)/g" "$REPORT_FILE"
sed -i.bak "s/\${BRANCH_NAME}/$EXPECTED_BRANCH/g" "$REPORT_FILE"
sed -i.bak "s/\${PREVIOUS_BRANCH_NAME}/$PREV_BRANCH/g" "$REPORT_FILE"
sed -i.bak "s/\${PRIMARY_FOCUS_AREA}/$REVIEW_FOCUS/g" "$REPORT_FILE"

# Clean up backup file
rm -f "$REPORT_FILE.bak"

echo "✅ Generated review report template at $REPORT_FILE"
echo "📋 Review focus for iteration $ITERATION_NUM: $REVIEW_FOCUS"

# If report-only flag is set, exit here
if [ "$REPORT_ONLY" = "true" ]; then
  echo "📄 Report template created. Now fill in the review details manually or using an AI assistant."
  exit 0
fi

# Prepare git diff for the AI review
if [ $ITERATION_NUM -gt 0 ]; then
  echo "📊 Generating diff between $PREV_BRANCH and $EXPECTED_BRANCH for AI review..."
  git diff $PREV_BRANCH..$EXPECTED_BRANCH > "docs/features/$FEATURE_NAME/reviews/iteration-${ITERATION_NUM}-diff.patch"
  
  # Get line count statistics
  echo "📊 Generating code statistics..."
  ADDED_LINES=$(git diff $PREV_BRANCH..$EXPECTED_BRANCH --stat | tail -n 1 | grep -o '[0-9]* insertion' | grep -o '[0-9]*')
  DELETED_LINES=$(git diff $PREV_BRANCH..$EXPECTED_BRANCH --stat | tail -n 1 | grep -o '[0-9]* deletion' | grep -o '[0-9]*')
  
  # Default to 0 if empty
  ADDED_LINES=${ADDED_LINES:-0}
  DELETED_LINES=${DELETED_LINES:-0}
  
  # Update the report with basic diff stats
  sed -i.bak "s/\${DIFF_SUMMARY}/Added: $ADDED_LINES lines, Deleted: $DELETED_LINES lines/g" "$REPORT_FILE"
  rm -f "$REPORT_FILE.bak"
fi

# Check if this is a CI environment (GitHub Actions)
if [ ! -z "$GITHUB_ACTIONS" ]; then
  echo "🤖 Running in CI environment. AI review will be handled by GitHub Actions."
  # In a real implementation, this would call the AI service to perform the review
  # For example: curl -X POST "https://api.openai.com/v1/..."
  exit 0
fi

echo "✅ Review preparation complete."
echo ""
echo "Next steps:"
echo "1. If working with an AI assistant, have it analyze the code and fill in the review report."
echo "2. Implement any recommended changes."
echo "3. When ready for the next iteration, run:"
echo "   ./scripts/ai-iterative-branch.sh $FEATURE_NAME <total-iterations> iterate $((ITERATION_NUM + 1))" 