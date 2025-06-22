#!/bin/sh
set -e

# Health Check Script for Helios Marketing Site Container
# This script validates multiple aspects of application health

# Configuration
HOST="localhost"
PORT="8080"
TIMEOUT="3"
RETRIES="3"

# Colors for output (when running manually)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Check if curl is available
if ! command -v curl > /dev/null 2>&1; then
    log "ERROR: curl is not available"
    exit 1
fi

# Function to check HTTP endpoint
check_endpoint() {
    local endpoint="$1"
    local expected_status="$2"
    local description="$3"
    
    log "Checking $description..."
    
    response=$(curl -s -o /dev/null -w "%{http_code}" \
        --connect-timeout "$TIMEOUT" \
        --max-time "$((TIMEOUT * 2))" \
        "http://$HOST:$PORT$endpoint" 2>/dev/null)
    
    if [ "$response" = "$expected_status" ]; then
        log "✓ $description: OK ($response)"
        return 0
    else
        log "✗ $description: FAILED (got $response, expected $expected_status)"
        return 1
    fi
}

# Function to check if process is running
check_process() {
    if pgrep nginx > /dev/null; then
        log "✓ Nginx process: OK"
        return 0
    else
        log "✗ Nginx process: NOT RUNNING"
        return 1
    fi
}

# Function to check disk space
check_disk_space() {
    # Check if we have at least 100MB free space
    available=$(df /tmp | tail -1 | awk '{print $4}')
    # Convert to MB (assuming KB units)
    available_mb=$((available / 1024))
    
    if [ "$available_mb" -gt 100 ]; then
        log "✓ Disk space: OK (${available_mb}MB available)"
        return 0
    else
        log "✗ Disk space: LOW (${available_mb}MB available)"
        return 1
    fi
}

# Function to check memory usage
check_memory() {
    # Get memory info
    mem_info=$(cat /proc/meminfo)
    mem_total=$(echo "$mem_info" | grep "MemTotal:" | awk '{print $2}')
    mem_available=$(echo "$mem_info" | grep "MemAvailable:" | awk '{print $2}')
    
    if [ -n "$mem_total" ] && [ -n "$mem_available" ]; then
        mem_usage_percent=$(( (mem_total - mem_available) * 100 / mem_total ))
        
        if [ "$mem_usage_percent" -lt 90 ]; then
            log "✓ Memory usage: OK (${mem_usage_percent}%)"
            return 0
        else
            log "✗ Memory usage: HIGH (${mem_usage_percent}%)"
            return 1
        fi
    else
        log "⚠ Memory usage: UNKNOWN (could not read /proc/meminfo)"
        return 0  # Don't fail health check for this
    fi
}

# Main health check routine
main() {
    log "Starting health check for Helios Marketing Site..."
    
    # Initialize counters
    checks_total=0
    checks_passed=0
    
    # Process check
    checks_total=$((checks_total + 1))
    if check_process; then
        checks_passed=$((checks_passed + 1))
    fi
    
    # Main site check
    checks_total=$((checks_total + 1))
    if check_endpoint "/" "200" "Main website"; then
        checks_passed=$((checks_passed + 1))
    fi
    
    # Health endpoint check
    checks_total=$((checks_total + 1))
    if check_endpoint "/health" "200" "Health endpoint"; then
        checks_passed=$((checks_passed + 1))
    fi
    
    # Detailed health endpoint check
    checks_total=$((checks_total + 1))
    if check_endpoint "/health/detailed" "200" "Detailed health endpoint"; then
        checks_passed=$((checks_passed + 1))
    fi
    
    # Resource checks
    checks_total=$((checks_total + 1))
    if check_disk_space; then
        checks_passed=$((checks_passed + 1))
    fi
    
    checks_total=$((checks_total + 1))
    if check_memory; then
        checks_passed=$((checks_passed + 1))
    fi
    
    # Check static assets (sample)
    checks_total=$((checks_total + 1))
    if check_endpoint "/assets/css/styles.css" "200" "CSS assets"; then
        checks_passed=$((checks_passed + 1))
    fi
    
    # Final result
    log "Health check completed: $checks_passed/$checks_total checks passed"
    
    if [ "$checks_passed" -eq "$checks_total" ]; then
        log "✓ ALL CHECKS PASSED - Container is healthy"
        exit 0
    elif [ "$checks_passed" -ge $((checks_total * 2 / 3)) ]; then
        log "⚠ PARTIAL SUCCESS - Container is degraded but functional"
        exit 0  # Still pass for minor issues
    else
        log "✗ HEALTH CHECK FAILED - Container is unhealthy"
        exit 1
    fi
}

# Handle script arguments
case "${1:-health}" in
    "health"|"")
        main
        ;;
    "quick")
        # Quick check - just verify main endpoint
        if check_endpoint "/" "200" "Quick health check"; then
            echo "healthy"
            exit 0
        else
            echo "unhealthy"
            exit 1
        fi
        ;;
    "verbose")
        # Verbose mode - same as main but with more output
        set -x
        main
        ;;
    *)
        echo "Usage: $0 [health|quick|verbose]"
        echo "  health   - Full health check (default)"
        echo "  quick    - Quick health check"
        echo "  verbose  - Verbose health check with debug output"
        exit 1
        ;;
esac 