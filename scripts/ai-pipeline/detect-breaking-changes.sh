#!/bin/bash

# Breaking Changes Detection Script
# This script checks if the AI-generated code introduces breaking changes

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

echo "Running Breaking Changes Detection for $FEATURE (Iteration $ITERATION)"

# Create a directory for storing breaking changes results
BREAKING_DIR="$WORKSPACE/.ai-pipeline-iterations/iteration-$ITERATION/step-breaking_changes"
mkdir -p "$BREAKING_DIR"

# In a real implementation, this would:
# 1. Check out the branch with AI changes
# 2. Run the existing test suite to see if tests still pass
# 3. Analyze API contracts for breaking changes
# 4. Check for database schema changes
# 5. Check for dependency changes
# 6. Check for config file changes

# For this dummy implementation, we'll:
# 1. List changed files
# 2. Simulate running tests
# 3. Simulate checking for API changes

# List changed files (if the branch exists)
git show-ref --verify --quiet refs/heads/$BRANCH
if [ $? -eq 0 ]; then
    # Branch exists, list changed files
    echo "Checking files changed in branch $BRANCH"
    git diff --name-only main..$BRANCH > "$BREAKING_DIR/changed_files.txt"
    CHANGED_COUNT=$(wc -l < "$BREAKING_DIR/changed_files.txt")
    echo "Found $CHANGED_COUNT changed files"
    
    # If there are no changed files, exit successfully
    if [ $CHANGED_COUNT -eq 0 ]; then
        echo "No files changed, breaking changes detection skipped"
        exit 0
    fi
else
    # Branch doesn't exist yet
    echo "Branch $BRANCH does not exist yet. Skipping file diff."
    echo "No files changed yet" > "$BREAKING_DIR/changed_files.txt"
    echo "No files changed, breaking changes detection skipped"
    exit 0
fi

# Categorize changed files
echo "Categorizing changed files..."
API_FILES=0
DB_FILES=0
UI_FILES=0
TEST_FILES=0
CONFIG_FILES=0
OTHER_FILES=0

while read -r file; do
    # Skip empty lines
    if [ -z "$file" ]; then
        continue
    fi
    
    # Categorize based on file path/type
    if [[ "$file" == *"/api/"* || "$file" == *"Service"* || "$file" == *"Controller"* ]]; then
        ((API_FILES++))
        echo "$file" >> "$BREAKING_DIR/api_files.txt"
    elif [[ "$file" == *"/db/"* || "$file" == *"Repository"* || "$file" == *"migration"* ]]; then
        ((DB_FILES++))
        echo "$file" >> "$BREAKING_DIR/db_files.txt"
    elif [[ "$file" == *"/ui/"* || "$file" == *"component"* || "$file" == *".css" || "$file" == *".html" ]]; then
        ((UI_FILES++))
        echo "$file" >> "$BREAKING_DIR/ui_files.txt"
    elif [[ "$file" == *"test"* || "$file" == *"spec"* ]]; then
        ((TEST_FILES++))
        echo "$file" >> "$BREAKING_DIR/test_files.txt"
    elif [[ "$file" == *"config"* || "$file" == *".json" || "$file" == *".yml" || "$file" == *".yaml" ]]; then
        ((CONFIG_FILES++))
        echo "$file" >> "$BREAKING_DIR/config_files.txt"
    else
        ((OTHER_FILES++))
        echo "$file" >> "$BREAKING_DIR/other_files.txt"
    fi
done < "$BREAKING_DIR/changed_files.txt"

# Simulate test runs
echo "Simulating test runs..."

# Set up test results based on iteration (later iterations should have fewer failures)
TEST_TOTAL=50
TEST_SKIPPED=$((RANDOM % 5))
TEST_FAILURES=0

if [ $ITERATION -eq 0 ]; then
    # First iteration, more test failures
    TEST_FAILURES=$((RANDOM % 10 + 5))
elif [ $ITERATION -lt 3 ]; then
    # Middle iterations, fewer failures
    TEST_FAILURES=$((RANDOM % 5 + 1))
else
    # Later iterations, minimal failures
    TEST_FAILURES=$((RANDOM % 2))
fi

TEST_PASSED=$((TEST_TOTAL - TEST_SKIPPED - TEST_FAILURES))

# Generate test results
cat > "$BREAKING_DIR/test_results.json" << EOL
{
  "tests": {
    "total": $TEST_TOTAL,
    "passed": $TEST_PASSED,
    "failed": $TEST_FAILURES,
    "skipped": $TEST_SKIPPED
  },
  "coverage": {
    "lines": $(( 70 + RANDOM % 25 )),
    "functions": $(( 75 + RANDOM % 20 )),
    "branches": $(( 65 + RANDOM % 30 )),
    "statements": $(( 75 + RANDOM % 20 ))
  }
}
EOL

# Simulate API compatibility check
echo "Checking API compatibility..."

# Set up API changes based on iteration and number of API files changed
API_BREAKING_CHANGES=0

if [ $API_FILES -gt 0 ]; then
    if [ $ITERATION -eq 0 ]; then
        # First iteration, more breaking changes
        API_BREAKING_CHANGES=$((RANDOM % 3 + 1))
    elif [ $ITERATION -lt 3 ]; then
        # Middle iterations, fewer breaking changes
        API_BREAKING_CHANGES=$((RANDOM % 2))
    else
        # Later iterations, likely no breaking changes
        API_BREAKING_CHANGES=0
    fi
fi

# Generate API changes report
cat > "$BREAKING_DIR/api_changes.json" << EOL
{
  "totalEndpoints": $(( 20 + RANDOM % 10 )),
  "endpointsModified": $API_FILES,
  "breakingChanges": $API_BREAKING_CHANGES,
  "changes": [
EOL

# Add some sample breaking changes if any
if [ $API_BREAKING_CHANGES -gt 0 ]; then
    for i in $(seq 1 $API_BREAKING_CHANGES); do
        if [ $i -gt 1 ]; then
            echo "    ," >> "$BREAKING_DIR/api_changes.json"
        fi
        
        # Generate a random breaking change type
        CHANGE_TYPE=""
        case $((RANDOM % 4)) in
            0) CHANGE_TYPE="Parameter Removed" ;;
            1) CHANGE_TYPE="Return Type Changed" ;;
            2) CHANGE_TYPE="Endpoint Removed" ;;
            3) CHANGE_TYPE="Authentication Requirement Changed" ;;
        esac
        
        cat >> "$BREAKING_DIR/api_changes.json" << EOL
    {
      "type": "$CHANGE_TYPE",
      "location": "api/v1/endpoint${i}",
      "severity": "HIGH",
      "description": "The API endpoint has changed in a way that will break existing clients"
    }
EOL
    done
fi

# Close the changes array
echo "  ]" >> "$BREAKING_DIR/api_changes.json"
echo "}" >> "$BREAKING_DIR/api_changes.json"

# Simulate database schema changes
echo "Checking database schema changes..."

DB_BREAKING_CHANGES=0

if [ $DB_FILES -gt 0 ]; then
    if [ $ITERATION -eq 0 ]; then
        # First iteration, more breaking changes
        DB_BREAKING_CHANGES=$((RANDOM % 2 + 1))
    elif [ $ITERATION -lt 3 ]; then
        # Middle iterations, fewer breaking changes
        DB_BREAKING_CHANGES=$((RANDOM % 2))
    else
        # Later iterations, likely no breaking changes
        DB_BREAKING_CHANGES=0
    fi
fi

# Generate DB changes report
cat > "$BREAKING_DIR/db_changes.json" << EOL
{
  "schemaChanges": $DB_FILES,
  "breakingChanges": $DB_BREAKING_CHANGES,
  "changes": [
EOL

# Add some sample breaking changes if any
if [ $DB_BREAKING_CHANGES -gt 0 ]; then
    for i in $(seq 1 $DB_BREAKING_CHANGES); do
        if [ $i -gt 1 ]; then
            echo "    ," >> "$BREAKING_DIR/db_changes.json"
        fi
        
        # Generate a random breaking change type
        CHANGE_TYPE=""
        case $((RANDOM % 3)) in
            0) CHANGE_TYPE="Column Removed" ;;
            1) CHANGE_TYPE="Table Renamed" ;;
            2) CHANGE_TYPE="Column Type Changed" ;;
        esac
        
        cat >> "$BREAKING_DIR/db_changes.json" << EOL
    {
      "type": "$CHANGE_TYPE",
      "location": "database/table${i}",
      "severity": "HIGH",
      "description": "The database schema has changed in a way that will break existing applications"
    }
EOL
    done
fi

# Close the changes array
echo "  ]" >> "$BREAKING_DIR/db_changes.json"
echo "}" >> "$BREAKING_DIR/db_changes.json"

# Create a summary
TOTAL_BREAKING_CHANGES=$((API_BREAKING_CHANGES + DB_BREAKING_CHANGES))

cat > "$BREAKING_DIR/summary.txt" << EOL
Breaking Changes Detection Summary for $FEATURE (Iteration $ITERATION)
=====================================================================
Files Analyzed: $CHANGED_COUNT
Tests Run: $TEST_TOTAL (Passed: $TEST_PASSED, Failed: $TEST_FAILURES, Skipped: $TEST_SKIPPED)
API Endpoints Modified: $API_FILES
Database Schema Changes: $DB_FILES
Total Breaking Changes: $TOTAL_BREAKING_CHANGES
EOL

# Exit based on results
if [ $TOTAL_BREAKING_CHANGES -gt 0 ]; then
    echo "WARNING: Detected $TOTAL_BREAKING_CHANGES breaking changes"
    
    # In a real implementation, you might want to fail on breaking changes
    # For demo, we'll just give a warning but succeed if not too many breaking changes
    if [ $TOTAL_BREAKING_CHANGES -gt 2 ]; then
        echo "ERROR: Too many breaking changes ($TOTAL_BREAKING_CHANGES). Pipeline cannot continue."
        exit 1
    else
        echo "WARNING: Breaking changes found, but continuing for demonstration purposes."
    fi
else
    echo "No breaking changes detected."
fi

if [ $TEST_FAILURES -gt 0 ]; then
    echo "WARNING: $TEST_FAILURES tests failed"
    
    # In a real implementation, you might want to fail on test failures
    # For demo, we'll just give a warning but succeed if not too many failures
    if [ $TEST_FAILURES -gt 5 ]; then
        echo "ERROR: Too many test failures ($TEST_FAILURES). Pipeline cannot continue."
        exit 1
    else
        echo "WARNING: Test failures found, but continuing for demonstration purposes."
    fi
else
    echo "All tests passed."
fi

echo "Breaking changes detection completed successfully"
exit 0 