#!/bin/bash

# Security Vulnerabilities Scan Script
# This script checks for potential security vulnerabilities in AI-generated code

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

echo "Running Security Scan for $FEATURE (Iteration $ITERATION)"

# Create a directory for storing security scan results
SECURITY_DIR="$WORKSPACE/.ai-pipeline-iterations/iteration-$ITERATION/step-security_scan"
mkdir -p "$SECURITY_DIR"

# In a real implementation, this would:
# 1. Run security scanning tools (e.g., SAST tools like Snyk, SonarQube)
# 2. Check for known vulnerabilities in dependencies
# 3. Look for hardcoded secrets, tokens, or credentials
# 4. Check for injection vulnerabilities, XSS, CSRF, etc.
# 5. Check for insecure configurations

# For this dummy implementation, we'll:
# 1. List changed files
# 2. Simulate security scanning with random results that improve over iterations

# List changed files (if the branch exists)
git show-ref --verify --quiet refs/heads/$BRANCH
if [ $? -eq 0 ]; then
    # Branch exists, list changed files
    echo "Checking files changed in branch $BRANCH"
    git diff --name-only main..$BRANCH > "$SECURITY_DIR/changed_files.txt"
    CHANGED_COUNT=$(wc -l < "$SECURITY_DIR/changed_files.txt")
    echo "Found $CHANGED_COUNT changed files"
    
    # If there are no changed files, exit successfully
    if [ $CHANGED_COUNT -eq 0 ]; then
        echo "No files changed, security scan skipped"
        exit 0
    fi
else
    # Branch doesn't exist yet
    echo "Branch $BRANCH does not exist yet. Skipping file diff."
    echo "No files changed yet" > "$SECURITY_DIR/changed_files.txt"
    echo "No files changed, security scan skipped"
    exit 0
fi

# Initialize results object
cat > "$SECURITY_DIR/security_results.json" << EOL
{
  "scan_timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "files_scanned": $CHANGED_COUNT,
  "vulnerabilities": []
}
EOL

# Function to add a vulnerability to the results
add_vulnerability() {
    local severity="$1"
    local type="$2"
    local description="$3"
    local file="$4"
    local line="$5"
    local remediation="$6"
    
    local vulnerability="{
        \"severity\": \"$severity\",
        \"type\": \"$type\",
        \"description\": \"$description\",
        \"file\": \"$file\",
        \"line\": $line,
        \"remediation\": \"$remediation\",
        \"id\": \"SEC-$(date +%s)-$RANDOM\"
    }"
    
    # Add to vulnerabilities array
    jq ".vulnerabilities += [$vulnerability]" "$SECURITY_DIR/security_results.json" > "$SECURITY_DIR/security_results.json.tmp"
    mv "$SECURITY_DIR/security_results.json.tmp" "$SECURITY_DIR/security_results.json"
}

# Define security vulnerability types and their details
declare -A VULN_TYPES
VULN_TYPES[0,type]="Injection"
VULN_TYPES[0,description]="SQL/NoSQL/Command injection vulnerability"
VULN_TYPES[0,remediation]="Use parameterized queries or prepared statements. Never concatenate user input directly into queries."

VULN_TYPES[1,type]="XSS"
VULN_TYPES[1,description]="Cross-site scripting vulnerability"
VULN_TYPES[1,remediation]="Sanitize user input, use content security policy, and implement output encoding."

VULN_TYPES[2,type]="HardcodedSecret"
VULN_TYPES[2,description]="Hardcoded secret, token, or credential"
VULN_TYPES[2,remediation]="Use environment variables or secure secrets management. Never hardcode sensitive information."

VULN_TYPES[3,type]="InsecureConfig"
VULN_TYPES[3,description]="Insecure configuration detected"
VULN_TYPES[3,remediation]="Follow secure configuration practices and enforce least privilege principle."

VULN_TYPES[4,type]="CSRF"
VULN_TYPES[4,description]="Cross-site request forgery vulnerability"
VULN_TYPES[4,remediation]="Implement anti-CSRF tokens for all state-changing operations."

VULN_TYPES[5,type]="PathTraversal"
VULN_TYPES[5,description]="Path traversal vulnerability"
VULN_TYPES[5,remediation]="Validate and sanitize user input. Use safe APIs for file operations."

VULN_TYPES[6,type]="Authentication"
VULN_TYPES[6,description]="Weak or insecure authentication"
VULN_TYPES[6,remediation]="Implement strong authentication mechanisms like multi-factor authentication."

VULN_TYPES[7,type]="Authorization"
VULN_TYPES[7,description]="Missing or improper authorization"
VULN_TYPES[7,remediation]="Implement proper access controls and verify authorization for all sensitive operations."

VULN_TYPES[8,type]="DataExposure"
VULN_TYPES[8,description]="Sensitive data exposure"
VULN_TYPES[8,remediation]="Encrypt sensitive data, minimize exposure, and implement proper access controls."

VULN_TYPES[9,type]="DependencyVulnerability"
VULN_TYPES[9,description]="Vulnerable dependency detected"
VULN_TYPES[9,remediation]="Update to the latest secure version of the dependency."

# Calculate number of vulnerabilities based on iteration
# Later iterations should have fewer vulnerabilities
MAX_VULNS=10
if [ $ITERATION -gt 0 ]; then
    MAX_VULNS=$((10 - ITERATION * 2))
    if [ $MAX_VULNS -lt 1 ]; then
        MAX_VULNS=1
    fi
fi

# For demonstration purposes, we'll generate random vulnerabilities
# Scale with the number of changed files - more files, potentially more issues
VULN_COUNT=$((RANDOM % (MAX_VULNS + 1)))
if [ $CHANGED_COUNT -gt 0 ] && [ $VULN_COUNT -gt $CHANGED_COUNT ]; then
    VULN_COUNT=$CHANGED_COUNT
fi

echo "Scanning for security vulnerabilities..."
echo "Detected $VULN_COUNT potential vulnerabilities"

# Generate random vulnerabilities
for i in $(seq 1 $VULN_COUNT); do
    # Select a random file from changed files
    FILE=$(shuf -n 1 "$SECURITY_DIR/changed_files.txt" 2>/dev/null || echo "unknown_file.txt")
    
    # Generate random line number
    LINE=$((RANDOM % 100 + 1))
    
    # Select random vulnerability type
    VULN_TYPE_INDEX=$((RANDOM % 10))
    VULN_TYPE="${VULN_TYPES[$VULN_TYPE_INDEX,type]}"
    VULN_DESC="${VULN_TYPES[$VULN_TYPE_INDEX,description]}"
    VULN_REMEDIATION="${VULN_TYPES[$VULN_TYPE_INDEX,remediation]}"
    
    # Select random severity based on iteration
    # Later iterations should have more minor/low severity issues rather than critical ones
    if [ $ITERATION -eq 0 ]; then
        # First iteration - more critical/high issues
        SEVERITY_INDEX=$((RANDOM % 5))
    elif [ $ITERATION -lt 3 ]; then
        # Middle iterations - fewer critical issues
        SEVERITY_INDEX=$((RANDOM % 5 + 1))
    else
        # Later iterations - mostly moderate/low issues
        SEVERITY_INDEX=$((RANDOM % 5 + 2))
    fi
    
    case $SEVERITY_INDEX in
        0) SEVERITY="critical" ;;
        1) SEVERITY="high" ;;
        2|3) SEVERITY="moderate" ;;
        4|5|6) SEVERITY="low" ;;
        *) SEVERITY="informational" ;;
    esac
    
    # Add vulnerability to results
    add_vulnerability "$SEVERITY" "$VULN_TYPE" "$VULN_DESC" "$FILE" "$LINE" "$VULN_REMEDIATION"
done

# Update results with severity counts
CRITICAL_COUNT=$(jq '.vulnerabilities | map(select(.severity == "critical")) | length' "$SECURITY_DIR/security_results.json")
HIGH_COUNT=$(jq '.vulnerabilities | map(select(.severity == "high")) | length' "$SECURITY_DIR/security_results.json")
MODERATE_COUNT=$(jq '.vulnerabilities | map(select(.severity == "moderate")) | length' "$SECURITY_DIR/security_results.json")
LOW_COUNT=$(jq '.vulnerabilities | map(select(.severity == "low")) | length' "$SECURITY_DIR/security_results.json")
INFO_COUNT=$(jq '.vulnerabilities | map(select(.severity == "informational")) | length' "$SECURITY_DIR/security_results.json")

jq ". += {\"summary\": {\"critical\": $CRITICAL_COUNT, \"high\": $HIGH_COUNT, \"moderate\": $MODERATE_COUNT, \"low\": $LOW_COUNT, \"informational\": $INFO_COUNT}}" "$SECURITY_DIR/security_results.json" > "$SECURITY_DIR/security_results.json.tmp"
mv "$SECURITY_DIR/security_results.json.tmp" "$SECURITY_DIR/security_results.json"

# Create a summary file
cat > "$SECURITY_DIR/summary.txt" << EOL
Security Scan Summary for $FEATURE (Iteration $ITERATION)
=======================================================
Files Scanned: $CHANGED_COUNT
Total Vulnerabilities: $VULN_COUNT

Severity Breakdown:
- Critical: $CRITICAL_COUNT
- High: $HIGH_COUNT
- Moderate: $MODERATE_COUNT
- Low: $LOW_COUNT
- Informational: $INFO_COUNT
EOL

# Generate a human-readable report
cat > "$SECURITY_DIR/security_report.md" << EOL
# Security Scan Report for $FEATURE (Iteration $ITERATION)

## Summary

- **Files Scanned**: $CHANGED_COUNT
- **Total Vulnerabilities**: $VULN_COUNT

## Severity Breakdown

- **Critical**: $CRITICAL_COUNT
- **High**: $HIGH_COUNT
- **Moderate**: $MODERATE_COUNT
- **Low**: $LOW_COUNT
- **Informational**: $INFO_COUNT

## Vulnerabilities by Type

EOL

# Add vulnerability types to the report
jq -r '.vulnerabilities | group_by(.type) | map({type: .[0].type, count: length}) | .[] | "- **\(.type)**: \(.count)"' "$SECURITY_DIR/security_results.json" >> "$SECURITY_DIR/security_report.md"

# Add critical and high vulnerabilities details
if [ $CRITICAL_COUNT -gt 0 ] || [ $HIGH_COUNT -gt 0 ]; then
    cat >> "$SECURITY_DIR/security_report.md" << EOL

## Critical & High Severity Issues

EOL
    jq -r '.vulnerabilities | map(select(.severity == "critical" or .severity == "high")) | .[] | "### [\(.severity | ascii_upcase)] \(.type) in \(.file) (line \(.line))\n\n\(.description)\n\n**Remediation**: \(.remediation)\n"' "$SECURITY_DIR/security_results.json" >> "$SECURITY_DIR/security_report.md"
fi

# Add recommendations
cat >> "$SECURITY_DIR/security_report.md" << EOL

## Recommendations

EOL

if [ $CRITICAL_COUNT -gt 0 ]; then
    echo "- **URGENT**: Address all critical vulnerabilities immediately before proceeding" >> "$SECURITY_DIR/security_report.md"
fi

if [ $HIGH_COUNT -gt 0 ]; then
    echo "- Address high severity issues as soon as possible" >> "$SECURITY_DIR/security_report.md"
fi

if [ $CRITICAL_COUNT -eq 0 ] && [ $HIGH_COUNT -eq 0 ] && [ $MODERATE_COUNT -gt 0 ]; then
    echo "- Review and fix moderate severity issues during this development cycle" >> "$SECURITY_DIR/security_report.md"
fi

if [ $VULN_COUNT -eq 0 ]; then
    echo "- No security issues detected. Continue monitoring for new vulnerabilities." >> "$SECURITY_DIR/security_report.md"
fi

# Check for critical issues that would block the pipeline
if [ $CRITICAL_COUNT -gt 0 ]; then
    echo "WARNING: Detected $CRITICAL_COUNT critical security vulnerabilities"
    
    # In a real implementation, critical vulnerabilities should block the pipeline
    # For demo, we'll just give a warning but succeed if it's the first iteration
    if [ $ITERATION -gt 0 ]; then
        echo "ERROR: Critical security vulnerabilities in later iterations. Pipeline cannot continue."
        exit 1
    else
        echo "WARNING: Critical vulnerabilities found, but continuing for demonstration purposes (first iteration)."
    fi
fi

if [ $HIGH_COUNT -gt 3 ]; then
    echo "WARNING: Detected $HIGH_COUNT high severity security vulnerabilities"
    
    # In a real implementation, too many high vulnerabilities might block the pipeline
    # For demo, we'll just give a warning but succeed
    echo "WARNING: Multiple high severity vulnerabilities found, but continuing for demonstration purposes."
fi

echo "Security scan completed successfully"
exit 0 