#!/bin/bash

# Syntax Check Script
# This script checks for syntax errors in the generated code

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

echo "Running Syntax Check for $FEATURE (Iteration $ITERATION)"

# Create a directory for storing syntax check results
SYNTAX_DIR="$WORKSPACE/.ai-pipeline-iterations/iteration-$ITERATION/step-syntax_check"
mkdir -p "$SYNTAX_DIR"

# In a real implementation, this would:
# 1. Check out the branch
# 2. Identify the language of each changed file
# 3. Run appropriate linters/syntax checkers for each language
# 4. Aggregate results

# For this dummy implementation, we'll:
# 1. List changed files (if the branch exists)
# 2. Simulate syntax checking for some common languages

# List changed files (if the branch exists)
git show-ref --verify --quiet refs/heads/$BRANCH
if [ $? -eq 0 ]; then
    # Branch exists, list changed files
    echo "Checking files changed in branch $BRANCH"
    git diff --name-only main..$BRANCH > "$SYNTAX_DIR/changed_files.txt"
    CHANGED_COUNT=$(wc -l < "$SYNTAX_DIR/changed_files.txt")
    echo "Found $CHANGED_COUNT changed files"
    
    # If there are no changed files, exit successfully
    if [ $CHANGED_COUNT -eq 0 ]; then
        echo "No files changed, syntax check skipped"
        exit 0
    fi
else
    # Branch doesn't exist yet
    echo "Branch $BRANCH does not exist yet. Skipping file diff."
    echo "No files changed yet" > "$SYNTAX_DIR/changed_files.txt"
    echo "No files changed, syntax check skipped"
    exit 0
fi

# Initialize results array
echo "[]" > "$SYNTAX_DIR/syntax_results.json"

# Function to simulate syntax check for a file
check_file_syntax() {
    local file="$1"
    local file_ext="${file##*.}"
    local language=""
    local syntax_tool=""
    
    # Determine language based on extension
    case "$file_ext" in
        js|jsx|ts|tsx)
            language="JavaScript/TypeScript"
            syntax_tool="ESLint"
            ;;
        py)
            language="Python"
            syntax_tool="pylint"
            ;;
        rb)
            language="Ruby"
            syntax_tool="rubocop"
            ;;
        java)
            language="Java"
            syntax_tool="javac"
            ;;
        php)
            language="PHP"
            syntax_tool="php -l"
            ;;
        go)
            language="Go"
            syntax_tool="go vet"
            ;;
        sh)
            language="Shell"
            syntax_tool="shellcheck"
            ;;
        *)
            language="Unknown"
            syntax_tool="generic"
            ;;
    esac
    
    echo "Checking syntax for $file ($language using $syntax_tool)"
    
    # Generate a random error count (for demo purposes)
    # Higher iterations should have fewer errors
    local max_errors=10
    if [ $ITERATION -gt 0 ]; then
        max_errors=$((10 - ITERATION * 2))
        if [ $max_errors -lt 0 ]; then
            max_errors=0
        fi
    fi
    
    local error_count=$((RANDOM % (max_errors + 1)))
    
    # Generate error messages (for demo purposes)
    local errors="[]"
    if [ $error_count -gt 0 ]; then
        errors="["
        for i in $(seq 1 $error_count); do
            line_num=$((RANDOM % 100 + 1))
            col_num=$((RANDOM % 50 + 1))
            
            # Generate a random error message
            case $((RANDOM % 5)) in
                0) msg="Syntax error: unexpected token" ;;
                1) msg="Variable not defined" ;;
                2) msg="Missing semicolon" ;;
                3) msg="Unexpected end of file" ;;
                4) msg="Parsing error" ;;
            esac
            
            errors="$errors{\"line\": $line_num, \"column\": $col_num, \"message\": \"$msg\"},"
        done
        errors="${errors%,}]"  # Remove trailing comma and close array
    fi
    
    # Create result object
    local result="{
        \"file\": \"$file\",
        \"language\": \"$language\",
        \"tool\": \"$syntax_tool\",
        \"error_count\": $error_count,
        \"errors\": $errors
    }"
    
    # Add to results array
    local current_results=$(cat "$SYNTAX_DIR/syntax_results.json")
    if [ "$current_results" = "[]" ]; then
        echo "[$result]" > "$SYNTAX_DIR/syntax_results.json"
    else
        # Remove closing bracket, add comma and new result, then close bracket
        sed -i.bak 's/\]$/,/' "$SYNTAX_DIR/syntax_results.json"
        echo "$result]" >> "$SYNTAX_DIR/syntax_results.json"
        rm -f "$SYNTAX_DIR/syntax_results.json.bak"
    fi
}

# Process each changed file
while read -r file; do
    # Skip empty lines
    if [ -z "$file" ]; then
        continue
    fi
    
    # Check if file exists
    if [ -f "$WORKSPACE/$file" ]; then
        check_file_syntax "$file"
    else
        echo "File $file does not exist, skipping"
    fi
done < "$SYNTAX_DIR/changed_files.txt"

# Calculate total errors
TOTAL_ERRORS=$(jq '[.[] | .error_count] | add' "$SYNTAX_DIR/syntax_results.json")
TOTAL_ERRORS=${TOTAL_ERRORS:-0}  # Default to 0 if jq fails

# Create summary file
cat > "$SYNTAX_DIR/summary.txt" << EOL
Syntax Check Summary for $FEATURE (Iteration $ITERATION)
=======================================================
Total Files Checked: $CHANGED_COUNT
Total Syntax Errors: $TOTAL_ERRORS
EOL

# Check if syntax check passed
if [ $TOTAL_ERRORS -gt 0 ]; then
    echo "Syntax check found $TOTAL_ERRORS errors"
    
    # In a real implementation, you might want to fail if errors are found
    # For demo, we'll just give a warning but succeed if not too many errors
    if [ $TOTAL_ERRORS -gt 5 ]; then
        echo "ERROR: Too many syntax errors ($TOTAL_ERRORS)"
        exit 1
    else
        echo "WARNING: Syntax errors found, but continuing for demonstration purposes"
    fi
else
    echo "Syntax check passed, no errors found"
fi

echo "Syntax check completed"
exit 0 