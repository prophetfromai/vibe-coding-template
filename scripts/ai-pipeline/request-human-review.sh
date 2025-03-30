#!/bin/bash

# Human Review Request Script
# This script notifies a human reviewer to provide feedback on the AI-generated code

# Default values
WORKSPACE="."
BRANCH="ai-generated-code"
ITERATION=0
FEATURE="feature"
DEBUG=false

# Parse command line arguments
for arg in "$@"; do
    case $arg in
        --workspace=*)
        WORKSPACE="${arg#*=}"
        shift
        ;;
        --branch=*)
        BRANCH="${arg#*=}"
        shift
        ;;
        --iteration=*)
        ITERATION="${arg#*=}"
        shift
        ;;
        --feature=*)
        FEATURE="${arg#*=}"
        shift
        ;;
        --debug)
        DEBUG=true
        shift
        ;;
        *)
        # Unknown option
        ;;
    esac
done

echo "Requesting Human Review for $FEATURE (Iteration $ITERATION)"

# Create a directory for storing human review results
REVIEW_DIR="$WORKSPACE/.ai-pipeline-iterations/iteration-$ITERATION/step-human_review"
mkdir -p "$REVIEW_DIR"

# In a real implementation, this would:
# 1. Gather all previous pipeline step results to provide context
# 2. Generate a comprehensive summary of the AI-generated code
# 3. Create a pull request or issue for human review
# 4. Send notification to human reviewers (email, Slack, etc.)
# 5. Wait for human approval, timeout, or rejection

# For this dummy implementation, we'll:
# 1. Collect information from previous steps
# 2. Generate a review summary
# 3. Simulate a human review response

# Collect information from previous steps
echo "Collecting information from previous pipeline steps..."

# Collect results from all previous step directories
PREV_STEPS=("context_validation" "syntax_check" "breaking_changes" "code_style" "security_scan" "ai_review")
SUMMARIES=()

for step in "${PREV_STEPS[@]}"; do
    STEP_DIR="$WORKSPACE/.ai-pipeline-iterations/iteration-$ITERATION/step-$step"
    if [ -d "$STEP_DIR" ] && [ -f "$STEP_DIR/summary.txt" ]; then
        SUMMARIES+=("$STEP_DIR/summary.txt")
    fi
done

# Create a comprehensive review summary document
cat > "$REVIEW_DIR/review_summary.md" << EOL
# Human Review Request for $FEATURE (Iteration $ITERATION)

## Overview

This document summarizes the AI-generated code changes and results from automated checks for your review.

- **Feature**: $FEATURE
- **Branch**: \`$BRANCH\`
- **Iteration**: $ITERATION
- **Date**: $(date -u +"%Y-%m-%d %H:%M:%S UTC")

## Changes Summary

EOL

# Get a summary of the changes
git show-ref --verify --quiet refs/heads/$BRANCH
if [ $? -eq 0 ]; then
    # Branch exists, summarize changes
    echo "Summarizing changes in branch $BRANCH"
    
    # Get stats
    git diff --stat main..$BRANCH > "$REVIEW_DIR/diff_stats.txt"
    FILES_CHANGED=$(git diff --name-only main..$BRANCH | wc -l)
    INSERTIONS=$(git diff --numstat main..$BRANCH | awk '{sum+=$1} END {print sum}')
    DELETIONS=$(git diff --numstat main..$BRANCH | awk '{sum+=$2} END {print sum}')
    
    cat >> "$REVIEW_DIR/review_summary.md" << EOL
- **Files Changed**: $FILES_CHANGED
- **Lines Added**: $INSERTIONS
- **Lines Removed**: $DELETIONS

\`\`\`
$(cat "$REVIEW_DIR/diff_stats.txt")
\`\`\`

## Changed Files

$(git diff --name-only main..$BRANCH | sed 's/^/- /')

EOL
else
    # Branch doesn't exist yet
    echo "Branch $BRANCH does not exist yet."
    
    cat >> "$REVIEW_DIR/review_summary.md" << EOL
No changes detected yet. Branch \`$BRANCH\` does not exist.

EOL
fi

# Add results from previous pipeline steps
cat >> "$REVIEW_DIR/review_summary.md" << EOL
## Pipeline Results Summary

EOL

for summary in "${SUMMARIES[@]}"; do
    cat >> "$REVIEW_DIR/review_summary.md" << EOL
### $(basename "$(dirname "$summary")" | sed 's/step-//' | tr '_' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); print}')

\`\`\`
$(cat "$summary")
\`\`\`

EOL
done

# Add AI review summary if available
AI_REVIEW_FILE="$WORKSPACE/.ai-pipeline-iterations/iteration-$ITERATION/step-ai_review/human_readable_review.md"
if [ -f "$AI_REVIEW_FILE" ]; then
    cat >> "$REVIEW_DIR/review_summary.md" << EOL
## AI Code Review

$(cat "$AI_REVIEW_FILE" | sed '1d')  # Skip the first line (title) since we already added a heading

EOL
fi

# Add specific review questions
cat >> "$REVIEW_DIR/review_summary.md" << EOL
## Review Questions

Please consider the following questions during your review:

1. Does the implemented code satisfy the requirements for the feature?
2. Are there any security concerns not caught by the automated checks?
3. Is the code maintainable and consistent with the project's style guidelines?
4. Are there any performance issues that should be addressed?
5. Is adequate error handling in place?
6. Is the code sufficiently tested?

## Review Instructions

Please provide your feedback in one of the following ways:

1. Comment directly on the pull request
2. Add comments to this document and commit back to the branch
3. Approve the changes to proceed with the next iteration

If there are critical issues, please reject the changes with detailed feedback.

EOL

# Simulate human review result
# In a real implementation, this would wait for actual human input
# For demo purposes, we'll randomly decide the outcome

# Add more success chance for later iterations
SUCCESS_CHANCE=60
if [ $ITERATION -gt 0 ]; then
    SUCCESS_CHANCE=$((60 + ITERATION * 10))
    if [ $SUCCESS_CHANCE -gt 95 ]; then
        SUCCESS_CHANCE=95
    fi
fi

RANDOM_OUTCOME=$((RANDOM % 100 + 1))
if [ $RANDOM_OUTCOME -le $SUCCESS_CHANCE ]; then
    REVIEW_RESULT="approved"
    REVIEW_COMMENTS="The changes look good. The code appears to be well-structured and follows our guidelines."
else
    REVIEW_RESULT="changes_requested"
    REVIEW_COMMENTS="Please address the following issues before proceeding: improve error handling, add more tests, and follow the naming conventions more consistently."
fi

# Create a simulated review result file
cat > "$REVIEW_DIR/review_result.json" << EOL
{
  "reviewer": "Simulated Human Reviewer",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "result": "$REVIEW_RESULT",
  "comments": "$REVIEW_COMMENTS"
}
EOL

# Create summary file
cat > "$REVIEW_DIR/summary.txt" << EOL
Human Review Request Summary for $FEATURE (Iteration $ITERATION)
==============================================================
Review Result: $REVIEW_RESULT
Reviewer: Simulated Human Reviewer
Comments: $REVIEW_COMMENTS
EOL

echo "Human review request completed successfully"
echo "Review Result: $REVIEW_RESULT"
echo "Comments: $REVIEW_COMMENTS"

# In a real implementation, we would not exit immediately but wait for feedback
# For demo, we'll just succeed regardless of the review result
exit 0 