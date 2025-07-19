#!/bin/bash

# Benchmark Suite Script - Dhrystone
# Collects execution times and system metrics for performance analysis

# Configuration
ITERATIONS=200
RESULTS_DIR="benchmark_results_$(date +%Y%m%d_%H%M%S)"
DHRYSTONE_EXEC="./dhrystone1_64"

# Create results directory
mkdir -p "$RESULTS_DIR"



# Run Dhrystone benchmark
run_dhrystone() {
    local results_file="$RESULTS_DIR/dhrystone_results.txt"
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
    echo "=== DHRYSTONE RESULTS ===" > "$results_file"
    echo "Start: $(date)" >> "$results_file"
    echo "" >> "$results_file"
    
    # Start sar monitoring (CPU only, 5 second intervals)
    sar -u 5 > "$sar_file" &
    SAR_PID=$!
    
    # Run iterations
    for ((i=1; i<=ITERATIONS; i++)); do
        echo "Running iteration $i/$ITERATIONS"
        
        start_time=$(date +%s%3N)
        echo "1000000" | $DHRYSTONE_EXEC 2>&1 | \
        grep -E "(Dhrystones per Second|VAX.*MIPS rating)" | \
        sed "s/^/Iteration $i: /" >> "$results_file"
        end_time=$(date +%s%3N)
        
        execution_time=$((end_time - start_time))
        echo "$i $execution_time" >> "$times_file"
    done
    
    # Stop sar
    kill $SAR_PID 2>/dev/null
    
    echo "End: $(date)" >> "$results_file"
    echo "Dhrystone completed. Results in $RESULTS_DIR/"
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

# Run benchmark
run_dhrystone

echo ""
echo "Benchmark completed!"
echo "Files created:"
echo "  - $RESULTS_DIR/dhrystone_times.txt (execution times)"
echo "  - $RESULTS_DIR/dhrystone_sar.txt (CPU metrics)"
echo "  - $RESULTS_DIR/dhrystone_results.txt (benchmark output)"