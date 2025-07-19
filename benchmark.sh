#!/bin/bash

# Benchmark Suite Script - Dhrystone, Whetstone, Linpack and Livermore
# Collects execution times and system metrics for performance analysis of two systems.

# With my calculations, 100 iterations of the full benchmark would take about 3.5 hours. So I decided to reduce the number of iterations to 20, which should take about 40 minutes.
ITERATIONS=25
RESULTS_DIR="benchmark_results_$(date +%Y%m%d_%H%M%S)"
DHRYSTONE_EXEC="./dhrystone1_64"
WHETSTONE_EXEC="./whetstone_64"
LINPACK_EXEC="./linpack_64"
LIVERMORE_EXEC="./lloops_64"

mkdir -p "$RESULTS_DIR"

run_dhrystone() {
    local times_file="$RESULTS_DIR/dhrystone_times.txt"
    local sar_file="$RESULTS_DIR/dhrystone_sar.txt"
    
    echo "Starting Dhrystone benchmark ($ITERATIONS iterations)..."
    
    if [[ ! -x "$DHRYSTONE_EXEC" ]]; then
        echo "Error: $DHRYSTONE_EXEC not found or not executable"
        exit 1
    fi
    
    echo "# Iteration execution time in milliseconds" > "$times_file"
    
    # Sar monitoring (5 second intervals).
    sar -u 5 > "$sar_file" &
    SAR_PID=$!
    
    for ((i=1; i<=ITERATIONS; i++)); do
        echo "Running iteration $i/$ITERATIONS"
        
        start_time=$(date +%s%3N)
        echo "1000000" | $DHRYSTONE_EXEC > /dev/null 2>&1
        end_time=$(date +%s%3N)
        
        execution_time=$((end_time - start_time))
        echo "$i $execution_time" >> "$times_file"
    done
    
    kill $SAR_PID 2>/dev/null
    
    echo "Dhrystone workload completed."
}

run_whetstone() {
    local times_file="$RESULTS_DIR/whetstone_times.txt"
    local sar_file="$RESULTS_DIR/whetstone_sar.txt"
    
    echo "Starting Whetstone benchmark ($ITERATIONS iterations)..."
    
    if [[ ! -x "$WHETSTONE_EXEC" ]]; then
        echo "Error: $WHETSTONE_EXEC not found or not executable"
        exit 1
    fi
    
    echo "# Iteration execution time in milliseconds" > "$times_file"
    
    # Sar monitoring (5 second intervals).
    sar -u 5 > "$sar_file" &
    SAR_PID=$!
    
    for ((i=1; i<=ITERATIONS; i++)); do
        echo "Running iteration $i/$ITERATIONS"
        
        start_time=$(date +%s%3N)
        echo "" | $WHETSTONE_EXEC > /dev/null 2>&1
        end_time=$(date +%s%3N)
        
        execution_time=$((end_time - start_time))
        echo "$i $execution_time" >> "$times_file"
    done
    
    kill $SAR_PID 2>/dev/null
    
    echo "Whetstone workload completed."
}

run_linpack() {
    local times_file="$RESULTS_DIR/linpack_times.txt"
    local pidstat_file="$RESULTS_DIR/linpack_pidstat.txt"
    
    echo "Starting Linpack benchmark ($ITERATIONS iterations)..."
    
    if [[ ! -x "$LINPACK_EXEC" ]]; then
        echo "Error: $LINPACK_EXEC not found or not executable"
        exit 1
    fi
    
    echo "# Iteration execution time in milliseconds" > "$times_file"
    
    # pidstat monitoring (5 second intervals)
    pidstat -u -C linpack_64 5 > "$pidstat_file" &
    PIDSTAT_PID=$!
    
    for ((i=1; i<=ITERATIONS; i++)); do
        echo "Running iteration $i/$ITERATIONS"
        
        start_time=$(date +%s%3N)
        echo "" | $LINPACK_EXEC > /dev/null 2>&1
        end_time=$(date +%s%3N)
        
        execution_time=$((end_time - start_time))
        echo "$i $execution_time" >> "$times_file"
    done
    
    kill $PIDSTAT_PID 2>/dev/null
    
    echo "Linpack workload completed."
}

run_livermore() {
    local times_file="$RESULTS_DIR/livermore_times.txt"
    local pidstat_file="$RESULTS_DIR/livermore_pidstat.txt"
    
    echo "Starting Livermore benchmark ($ITERATIONS iterations)..."
    
    if [[ ! -x "$LIVERMORE_EXEC" ]]; then
        echo "Error: $LIVERMORE_EXEC not found or not executable"
        exit 1
    fi
    
    echo "# Iteration execution time in milliseconds" > "$times_file"
    
    # pidstat monitoring (5 second intervals)
    pidstat -u -C lloops_64 5 > "$pidstat_file" &
    PIDSTAT_PID=$!
    
    for ((i=1; i<=ITERATIONS; i++)); do
        echo "Running iteration $i/$ITERATIONS"
        
        start_time=$(date +%s%3N)
        echo "" | $LIVERMORE_EXEC > /dev/null 2>&1
        end_time=$(date +%s%3N)
        
        execution_time=$((end_time - start_time))
        echo "$i $execution_time" >> "$times_file"
    done
    
    kill $PIDSTAT_PID 2>/dev/null
    
    echo "Livermore workload completed."
}

echo "=== BENCHMARK SUITE ==="
echo "Results directory: $RESULTS_DIR"
echo ""

# Dependencies checking
if ! command -v sar >/dev/null 2>&1; then
    echo "Error: sar not found."
    exit 1
fi

if ! command -v pidstat >/dev/null 2>&1; then
    echo "Error: pidstat not found."
    exit 1
fi

# Run all benchmarks
run_dhrystone
run_whetstone
run_linpack
run_livermore

echo ""
echo "Benchmark completed!"
