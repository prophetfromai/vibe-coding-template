#!/bin/bash

# Code Style Verification Script
# This script checks if the AI-generated code adheres to repository code style guidelines

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

echo "Running Code Style Verification for $FEATURE (Iteration $ITERATION)"

# Create a directory for storing code style results
STYLE_DIR="$WORKSPACE/.ai-pipeline-iterations/iteration-$ITERATION/step-code_style"
mkdir -p "$STYLE_DIR"

# In a real implementation, this would:
# 1. Run appropriate linters for each language
# 2. Check naming conventions against repository standards
# 3. Verify formatting (indentation, line length, etc.)
# 4. Check comment quality and documentation

# For this dummy implementation, we'll:
# 1. List changed files
# 2. Simulate style checking with random results that improve over iterations

# List changed files (if the branch exists)
git show-ref --verify --quiet refs/heads/$BRANCH
if [ $? -eq 0 ]; then
    # Branch exists, list changed files
    echo "Checking files changed in branch $BRANCH"
    git diff --name-only main..$BRANCH > "$STYLE_DIR/changed_files.txt"
    CHANGED_COUNT=$(wc -l < "$STYLE_DIR/changed_files.txt")
    echo "Found $CHANGED_COUNT changed files"
    
    # If there are no changed files, exit successfully
    if [ $CHANGED_COUNT -eq 0 ]; then
        echo "No files changed, code style verification skipped"
        exit 0
    fi
else
    # Branch doesn't exist yet
    echo "Branch $BRANCH does not exist yet. Skipping file diff."
    echo "No files changed yet" > "$STYLE_DIR/changed_files.txt"
    echo "No files changed, code style verification skipped"
    exit 0
fi

# Initialize results array
echo "[]" > "$STYLE_DIR/style_results.json"

# Function to simulate style check for a file
check_file_style() {
    local file="$1"
    local file_ext="${file##*.}"
    local language=""
    local style_tool=""
    
    # Determine language based on extension
    case "$file_ext" in
        js|jsx|ts|tsx)
            language="JavaScript/TypeScript"
            style_tool="ESLint/Prettier"
            ;;
        py)
            language="Python"
            style_tool="Black/Flake8"
            ;;
        rb)
            language="Ruby"
            style_tool="RuboCop"
            ;;
        java)
            language="Java"
            style_tool="Checkstyle"
            ;;
        php)
            language="PHP"
            style_tool="PHP_CodeSniffer"
            ;;
        go)
            language="Go"
            style_tool="gofmt"
            ;;
        sh)
            language="Shell"
            style_tool="shellcheck"
            ;;
        *)
            language="Unknown"
            style_tool="generic"
            ;;
    esac
    
    echo "Checking style for $file ($language using $style_tool)"
    
    # Generate a random error count that decreases with iterations
    # Higher iterations should have fewer style issues
    local max_issues=20
    if [ $ITERATION -gt 0 ]; then
        max_issues=$((20 - ITERATION * 5))
        if [ $max_issues -lt 3 ]; then
            max_issues=3
        fi
    fi
    
    local issue_count=$((RANDOM % (max_issues + 1)))
    
    # Generate style issues (for demo purposes)
    local issues="[]"
    if [ $issue_count -gt 0 ]; then
        issues="["
        for i in $(seq 1 $issue_count); do
            line_num=$((RANDOM % 100 + 1))
            col_num=$((RANDOM % 50 + 1))
            
            # Generate a random style issue message
            case $((RANDOM % 5)) in
                0) msg="Line too long (exceeds maximum length)" ;;
                1) msg="Inconsistent indentation" ;;
                2) msg="Missing/extra space" ;;
                3) msg="Non-standard naming convention" ;;
                4) msg="Missing or improper documentation" ;;
            esac
            
            issues="$issues{\"line\": $line_num, \"column\": $col_num, \"message\": \"$msg\"},"
        done
        issues="${issues%,}]"  # Remove trailing comma and close array
    fi
    
    # Create result object
    local result="{
        \"file\": \"$file\",
        \"language\": \"$language\",
        \"tool\": \"$style_tool\",
        \"issue_count\": $issue_count,
        \"issues\": $issues
    }"
    
    # Add to results array
    local current_results=$(cat "$STYLE_DIR/style_results.json")
    if [ "$current_results" = "[]" ]; then
        echo "[$result]" > "$STYLE_DIR/style_results.json"
    else
        # Remove closing bracket, add comma and new result, then close bracket
        sed -i.bak 's/\]$/,/' "$STYLE_DIR/style_results.json"
        echo "$result]" >> "$STYLE_DIR/style_results.json"
        rm -f "$STYLE_DIR/style_results.json.bak"
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
        check_file_style "$file"
    else
        echo "File $file does not exist, skipping"
    fi
done < "$STYLE_DIR/changed_files.txt"

# Calculate total issues
TOTAL_ISSUES=$(jq '[.[] | .issue_count] | add' "$STYLE_DIR/style_results.json")
TOTAL_ISSUES=${TOTAL_ISSUES:-0}  # Default to 0 if jq fails

# Create a breakdown of style issue types (simulated)
INDENTATION_ISSUES=$((RANDOM % (TOTAL_ISSUES / 3 + 1)))
NAMING_ISSUES=$((RANDOM % (TOTAL_ISSUES / 3 + 1)))
LINE_LENGTH_ISSUES=$((RANDOM % (TOTAL_ISSUES / 3 + 1)))
DOCUMENTATION_ISSUES=$((TOTAL_ISSUES - INDENTATION_ISSUES - NAMING_ISSUES - LINE_LENGTH_ISSUES))
if [ $DOCUMENTATION_ISSUES -lt 0 ]; then
    DOCUMENTATION_ISSUES=0
fi

# Create summary file
cat > "$STYLE_DIR/summary.txt" << EOL
Code Style Verification Summary for $FEATURE (Iteration $ITERATION)
==================================================================
Total Files Checked: $CHANGED_COUNT
Total Style Issues: $TOTAL_ISSUES

Issue Breakdown:
- Indentation Issues: $INDENTATION_ISSUES
- Naming Convention Issues: $NAMING_ISSUES
- Line Length Issues: $LINE_LENGTH_ISSUES
- Documentation Issues: $DOCUMENTATION_ISSUES
EOL

# Check if style verification passed
if [ $TOTAL_ISSUES -gt 0 ]; then
    echo "Style verification found $TOTAL_ISSUES issues"
    
    # Style issues are typically not blocking, but might be in more strict environments
    if [ $TOTAL_ISSUES -gt 50 ]; then
        echo "WARNING: Too many style issues ($TOTAL_ISSUES), but continuing"
    fi
else
    echo "Style verification passed, no issues found"
fi

# Generate a human-readable report
cat > "$STYLE_DIR/style_report.md" << EOL
# Code Style Report for $FEATURE (Iteration $ITERATION)

## Summary

- **Files Analyzed**: $CHANGED_COUNT
- **Total Style Issues**: $TOTAL_ISSUES

## Issue Breakdown

- **Indentation Issues**: $INDENTATION_ISSUES
- **Naming Convention Issues**: $NAMING_ISSUES
- **Line Length Issues**: $LINE_LENGTH_ISSUES
- **Documentation Issues**: $DOCUMENTATION_ISSUES

## Files with Most Issues

EOL

# Add files with most issues to the report
jq -r 'sort_by(.issue_count) | reverse | .[0:5] | .[] | "- **\(.file)**: \(.issue_count) issues"' "$STYLE_DIR/style_results.json" >> "$STYLE_DIR/style_report.md"

cat >> "$STYLE_DIR/style_report.md" << EOL

## Recommendations

EOL

# Add recommendations based on the types of issues
if [ $INDENTATION_ISSUES -gt 10 ]; then
    echo "- Configure your editor to use consistent indentation and use an auto-formatter" >> "$STYLE_DIR/style_report.md"
fi

if [ $NAMING_ISSUES -gt 10 ]; then
    echo "- Review naming conventions in the project's style guide and apply them consistently" >> "$STYLE_DIR/style_report.md"
fi

if [ $LINE_LENGTH_ISSUES -gt 10 ]; then
    echo "- Break long lines into multiple lines for better readability" >> "$STYLE_DIR/style_report.md"
fi

if [ $DOCUMENTATION_ISSUES -gt 10 ]; then
    echo "- Add appropriate documentation to public functions, classes, and modules" >> "$STYLE_DIR/style_report.md"
fi

echo "Code style verification completed"
exit 0 