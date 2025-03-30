#!/bin/bash

set -e

# Colors for better output formatting
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CONFIG_FILE="config/ai-pipeline.json"
WORKSPACE_DIR="$PWD"
ITERATIONS_DIR="$WORKSPACE_DIR/.ai-pipeline-iterations"
CURRENT_ITERATION=0
MAX_ITERATIONS=5
PIPELINE_RESULTS_FILE="$WORKSPACE_DIR/.ai-pipeline-results.json"

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is required but not installed. Please install jq to parse JSON.${NC}"
    exit 1
fi

# Function to display help information
show_help() {
    echo "AI Safe Pipeline Runner"
    echo "----------------------"
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --branch=NAME        Branch name for the AI changes (default: ai-generated-code)"
    echo "  --max-iterations=N   Maximum number of iterations (default: 5)"
    echo "  --feature=NAME       Feature name or description"
    echo "  --help               Show this help message"
    echo ""
}

# Parse command line arguments
for arg in "$@"; do
    case $arg in
        --branch=*)
        BRANCH_NAME="${arg#*=}"
        shift
        ;;
        --max-iterations=*)
        MAX_ITERATIONS="${arg#*=}"
        shift
        ;;
        --feature=*)
        FEATURE_NAME="${arg#*=}"
        shift
        ;;
        --help)
        show_help
        exit 0
        ;;
        *)
        # Unknown option
        ;;
    esac
done

# Set default branch name if not provided
BRANCH_NAME=${BRANCH_NAME:-ai-generated-code}
FEATURE_NAME=${FEATURE_NAME:-feature}

# Create directories for storing iteration data
mkdir -p "$ITERATIONS_DIR"

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}    AI Safe Pipeline Runner    ${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""
echo -e "Branch: ${GREEN}$BRANCH_NAME${NC}"
echo -e "Feature: ${GREEN}$FEATURE_NAME${NC}"
echo -e "Max Iterations: ${GREEN}$MAX_ITERATIONS${NC}"
echo ""

# Check if configuration file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}Error: Configuration file not found at $CONFIG_FILE${NC}"
    exit 1
fi

# Load configuration values
MIN_STEPS=$(jq -r '.pipeline.min_steps' "$CONFIG_FILE")
MAX_STEPS=$(jq -r '.pipeline.max_steps' "$CONFIG_FILE")
STEPS_COUNT=$(jq -r '.pipeline.steps | length' "$CONFIG_FILE")

echo -e "Pipeline Configuration:"
echo -e "  Min Steps: ${GREEN}$MIN_STEPS${NC}"
echo -e "  Max Steps: ${GREEN}$MAX_STEPS${NC}"
echo -e "  Available Steps: ${GREEN}$STEPS_COUNT${NC}"
echo ""

# Initialize results file
echo "{\"iterations\": []}" > "$PIPELINE_RESULTS_FILE"

# Function to run a pipeline step
run_step() {
    local step_id=$1
    local iteration=$2
    
    # Get step details from config
    local step_name=$(jq -r ".pipeline.steps[] | select(.id == \"$step_id\") | .name" "$CONFIG_FILE")
    local step_script=$(jq -r ".pipeline.steps[] | select(.id == \"$step_id\") | .script" "$CONFIG_FILE")
    local step_required=$(jq -r ".pipeline.steps[] | select(.id == \"$step_id\") | .required" "$CONFIG_FILE")
    local step_timeout=$(jq -r ".pipeline.steps[] | select(.id == \"$step_id\") | .timeout_seconds" "$CONFIG_FILE")
    
    # Create a directory for this step's output
    local step_dir="$ITERATIONS_DIR/iteration-$iteration/step-$step_id"
    mkdir -p "$step_dir"
    
    echo -e "${YELLOW}Running Step: $step_name${NC}"
    
    # Check if script exists
    if [ ! -f "$step_script" ]; then
        echo -e "${RED}Warning: Step script not found at $step_script${NC}"
        
        if [ "$step_required" = "true" ]; then
            echo -e "${RED}Error: Required step failed${NC}"
            return 1
        else
            echo -e "${YELLOW}Skipping non-required step${NC}"
            return 0
        fi
    fi
    
    # Make sure the script is executable
    chmod +x "$step_script"
    
    # Run the step script with a timeout
    local start_time=$(date +%s)
    local output_file="$step_dir/output.log"
    local status_file="$step_dir/status.json"
    
    # Run the script with parameters
    "$step_script" \
        --workspace="$WORKSPACE_DIR" \
        --branch="$BRANCH_NAME" \
        --iteration="$iteration" \
        --feature="$FEATURE_NAME" \
        > "$output_file" 2>&1
    
    local exit_code=$?
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Create status JSON
    echo "{
        \"step_id\": \"$step_id\",
        \"step_name\": \"$step_name\",
        \"exit_code\": $exit_code,
        \"duration_seconds\": $duration,
        \"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"
    }" > "$status_file"
    
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✓ Step completed successfully${NC}"
        return 0
    else
        echo -e "${RED}✗ Step failed with exit code $exit_code${NC}"
        if [ "$step_required" = "true" ]; then
            echo -e "${RED}Error: Required step failed${NC}"
            return 1
        else
            echo -e "${YELLOW}Continuing despite non-required step failure${NC}"
            return 0
        fi
    fi
}

# Function to run a complete iteration
run_iteration() {
    local iteration=$1
    local iteration_dir="$ITERATIONS_DIR/iteration-$iteration"
    
    echo -e "${BLUE}=====================================${NC}"
    echo -e "${BLUE}    Starting Iteration $iteration    ${NC}"
    echo -e "${BLUE}=====================================${NC}"
    
    mkdir -p "$iteration_dir"
    
    # Determine number of steps to run (random between min and max)
    local num_steps=$(jq -r ".pipeline.steps | length" "$CONFIG_FILE")
    local steps_to_run=$(( (RANDOM % (MAX_STEPS - MIN_STEPS + 1)) + MIN_STEPS ))
    steps_to_run=$(( steps_to_run < num_steps ? steps_to_run : num_steps ))
    
    echo -e "Running ${GREEN}$steps_to_run${NC} steps for this iteration"
    
    # Initialize iteration results
    local iteration_results="{
        \"iteration\": $iteration,
        \"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\",
        \"steps_run\": $steps_to_run,
        \"steps\": []
    }"
    
    # Run required steps first
    local required_steps=$(jq -r '.pipeline.steps[] | select(.required == true) | .id' "$CONFIG_FILE")
    for step_id in $required_steps; do
        run_step "$step_id" "$iteration"
        local step_exit_code=$?
        
        # Add step result to iteration results
        local step_result=$(cat "$iteration_dir/step-$step_id/status.json")
        iteration_results=$(echo "$iteration_results" | jq ".steps += [$step_result]")
        
        if [ $step_exit_code -ne 0 ]; then
            echo -e "${RED}Iteration failed at required step $step_id${NC}"
            
            # Update the iteration results with failure status
            iteration_results=$(echo "$iteration_results" | jq ". += {\"status\": \"failed\", \"failed_step\": \"$step_id\"}")
            
            # Update the main results file
            jq ".iterations += [$(echo "$iteration_results")]" "$PIPELINE_RESULTS_FILE" > "$PIPELINE_RESULTS_FILE.tmp"
            mv "$PIPELINE_RESULTS_FILE.tmp" "$PIPELINE_RESULTS_FILE"
            
            return 1
        fi
    done
    
    # Run optional steps until we reach steps_to_run
    local optional_steps=$(jq -r '.pipeline.steps[] | select(.required == false) | .id' "$CONFIG_FILE")
    local required_count=$(echo "$required_steps" | wc -w | tr -d ' ')
    local optional_count=$(( steps_to_run - required_count ))
    
    if [ $optional_count -gt 0 ]; then
        # Randomize optional steps
        local shuffled_optional=$(echo "$optional_steps" | tr ' ' '\n' | shuf | head -n $optional_count)
        
        for step_id in $shuffled_optional; do
            run_step "$step_id" "$iteration"
            
            # Add step result to iteration results
            local step_result=$(cat "$iteration_dir/step-$step_id/status.json")
            iteration_results=$(echo "$iteration_results" | jq ".steps += [$step_result]")
        done
    fi
    
    # Update the iteration results with success status
    iteration_results=$(echo "$iteration_results" | jq ". += {\"status\": \"success\"}")
    
    # Update the main results file
    jq ".iterations += [$(echo "$iteration_results")]" "$PIPELINE_RESULTS_FILE" > "$PIPELINE_RESULTS_FILE.tmp"
    mv "$PIPELINE_RESULTS_FILE.tmp" "$PIPELINE_RESULTS_FILE"
    
    echo -e "${GREEN}Iteration $iteration completed successfully${NC}"
    return 0
}

# Function to check if stopping conditions are met
check_stopping_conditions() {
    local iteration=$1
    
    # Check if max iterations reached
    if [ $iteration -ge $MAX_ITERATIONS ]; then
        echo -e "${YELLOW}Stopping: Maximum iterations reached${NC}"
        return 0
    fi
    
    # Check for no errors in the last iteration
    local last_status=$(jq -r ".iterations[$iteration].status" "$PIPELINE_RESULTS_FILE")
    if [ "$last_status" = "success" ]; then
        # Check if all steps passed with no warnings
        local warnings_found=$(jq -r ".iterations[$iteration].steps[] | select(.warnings > 0) | .step_id" "$PIPELINE_RESULTS_FILE")
        if [ -z "$warnings_found" ]; then
            echo -e "${GREEN}Stopping: No errors or warnings found in iteration $iteration${NC}"
            return 0
        fi
    fi
    
    # Continue iterations
    return 1
}

# Main execution loop
while [ $CURRENT_ITERATION -lt $MAX_ITERATIONS ]; do
    run_iteration $CURRENT_ITERATION
    ITERATION_EXIT_CODE=$?
    
    if [ $ITERATION_EXIT_CODE -ne 0 ]; then
        echo -e "${RED}Pipeline stopped due to errors in iteration $CURRENT_ITERATION${NC}"
        exit 1
    fi
    
    # Check if stopping conditions are met
    check_stopping_conditions $CURRENT_ITERATION
    if [ $? -eq 0 ]; then
        break
    fi
    
    CURRENT_ITERATION=$((CURRENT_ITERATION + 1))
done

echo -e "${BLUE}=====================================${NC}"
echo -e "${GREEN}Pipeline completed successfully after $((CURRENT_ITERATION + 1)) iterations${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""
echo -e "Results saved to: ${YELLOW}$PIPELINE_RESULTS_FILE${NC}"
echo ""

# Generate a summary
echo -e "${BLUE}Pipeline Summary:${NC}"
jq -r '.iterations[] | "Iteration \(.iteration): \(.status)"' "$PIPELINE_RESULTS_FILE"

exit 0 