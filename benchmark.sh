#!/bin/bash

# Benchmark Suite Script - Dhrystone and Whetstone
# Collects execution times and system metrics for performance analysis

# Configuration
ITERATIONS=3
RESULTS_DIR="benchmark_results_$(date +%Y%m%d_%H%M%S)"
DHRYSTONE_EXEC="./dhrystone1_64"
WHETSTONE_EXEC="./whetstone_64"

# Create results directory
mkdir -p "$RESULTS_DIR"

# Run Dhrystone benchmark
run_dhrystone() {
    local times_file="$RESULTS_DIR/dhrystone_times.txt"
    local sar_file="$RESULTS_DIR/dhrystone_sar.txt"
    
    echo "Starting Dhrystone benchmark ($ITERATIONS iterations)..."
    
    # Check executable
    if [[ ! -x "$DHRYSTONE_EXEC" ]]; then
        echo "Error: $DHRYSTONE_EXEC not found or not executable"
        exit 1
    fi
    
    # Initialize files
    echo "# Iteration Execution_Time_Milliseconds" > "$times_file"
    
    # Start sar monitoring (CPU only, 5 second intervals)
    sar -u 5 > "$sar_file" &
    SAR_PID=$!
    
    # Run iterations
    for ((i=1; i<=ITERATIONS; i++)); do
        echo "Running iteration $i/$ITERATIONS"
        
        start_time=$(date +%s%3N)
        echo "1000000" | $DHRYSTONE_EXEC > /dev/null 2>&1
        end_time=$(date +%s%3N)
        
        execution_time=$((end_time - start_time))
        echo "$i $execution_time" >> "$times_file"
    done
    
    # Stop sar
    kill $SAR_PID 2>/dev/null
    
    echo "Dhrystone completed. Results in $RESULTS_DIR/"
}

# Run Whetstone benchmark
run_whetstone() {
    local times_file="$RESULTS_DIR/whetstone_times.txt"
    local sar_file="$RESULTS_DIR/whetstone_sar.txt"
    
    echo "Starting Whetstone benchmark ($ITERATIONS iterations)..."
    
    # Check executable
    if [[ ! -x "$WHETSTONE_EXEC" ]]; then
        echo "Error: $WHETSTONE_EXEC not found or not executable"
        exit 1
    fi
    
    # Initialize files
    echo "# Iteration Execution_Time_Milliseconds" > "$times_file"
    
    # Start sar monitoring (CPU only, 5 second intervals)
    sar -u 5 > "$sar_file" &
    SAR_PID=$!
    
    # Run iterations
    for ((i=1; i<=ITERATIONS; i++)); do
        echo "Running iteration $i/$ITERATIONS"
        
        start_time=$(date +%s%3N)
        echo "" | $WHETSTONE_EXEC > /dev/null 2>&1
        end_time=$(date +%s%3N)
        
        execution_time=$((end_time - start_time))
        echo "$i $execution_time" >> "$times_file"
    done
    
    # Stop sar
    kill $SAR_PID 2>/dev/null
    
    echo "Whetstone completed. Results in $RESULTS_DIR/"
}

# Main execution
echo "=== BENCHMARK SUITE ==="
echo "Results directory: $RESULTS_DIR"
echo ""

# Check dependencies
if ! command -v sar >/dev/null 2>&1; then
    echo "Error: sar not found. Install with: apt-get install sysstat"
    exit 1
fi

# Run benchmarks
run_dhrystone
run_whetstone

echo ""
echo "Benchmark completed!"
echo "Files created:"
echo "  Dhrystone:"
echo "    - $RESULTS_DIR/dhrystone_times.txt (execution times)"
echo "    - $RESULTS_DIR/dhrystone_sar.txt (CPU metrics)"
#    echo "    - $RESULTS_DIR/dhrystone_results.txt (benchmark output)"
echo "  Whetstone:"
echo "    - $RESULTS_DIR/whetstone_times.txt (execution times)"
echo "    - $RESULTS_DIR/whetstone_sar.txt (CPU metrics)"
#    echo "    - $RESULTS_DIR/whetstone_results.txt (benchmark output)"