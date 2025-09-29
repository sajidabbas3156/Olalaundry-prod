#!/bin/bash

# OLA Laundry Master - Production Deployment Verification Script
# Comprehensive health checks and verification procedures

set -e

# Configuration
DOMAIN="www.olalaundry.com"
LOCAL_PORT="5000"
SERVICE_NAME="olalaundry"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Test function
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    echo -e "${BLUE}🧪 Testing: $test_name${NC}"
    
    if eval "$test_command"; then
        echo -e "${GREEN}✅ PASS: $test_name${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}❌ FAIL: $test_name${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

echo -e "${BLUE}🚀 OLA Laundry Master - Production Deployment Verification${NC}"
echo "=================================================="

# Test 1: PM2 Service Status
run_test "PM2 Service Running" \
    "pm2 jlist | jq -r '.[] | select(.name==\"$SERVICE_NAME\") | .pm2_env.status' | grep -q 'online'" \
    "online"

# Test 2: Local Health Check
run_test "Local Health Endpoint" \
    "curl -f -s http://localhost:$LOCAL_PORT/api/health > /dev/null" \
    "200"

# Test 3: Application Port Listening
run_test "Application Port Listening" \
    "netstat -tlnp | grep -q ':$LOCAL_PORT'" \
    "listening"

# Test 4: Database Connection (if applicable)
run_test "Database Connection" \
    "curl -f -s http://localhost:$LOCAL_PORT/api/health | grep -q 'database'" \
    "database ok"

# Test 5: Static Files Serving
run_test "Static Files Accessible" \
    "curl -f -s http://localhost:$LOCAL_PORT/ | grep -q 'OLA Laundry'" \
    "html content"

# Test 6: API Authentication Endpoint
run_test "Authentication API" \
    "curl -f -s http://localhost:$LOCAL_PORT/api/auth/me > /dev/null" \
    "auth endpoint"

# Test 7: Memory Usage Check
run_test "Memory Usage Acceptable" \
    "pm2 jlist | jq -r '.[] | select(.name==\"$SERVICE_NAME\") | .monit.memory' | awk '{if(\$1 < 1073741824) exit 0; else exit 1}'" \
    "< 1GB"

# Test 8: CPU Usage Check
run_test "CPU Usage Acceptable" \
    "pm2 jlist | jq -r '.[] | select(.name==\"$SERVICE_NAME\") | .monit.cpu' | awk '{if(\$1 < 80) exit 0; else exit 1}'" \
    "< 80%"

# Test 9: Log Files Accessible
run_test "Log Files Accessible" \
    "test -f /var/log/olalaundry/error.log -o -f /var/log/olalaundry/combined.log" \
    "log files exist"

# Test 10: Nginx Configuration
if command -v nginx > /dev/null; then
    run_test "Nginx Configuration Valid" \
        "nginx -t 2>/dev/null" \
        "syntax ok"
    
    run_test "Nginx Service Running" \
        "systemctl is-active nginx | grep -q 'active'" \
        "active"
fi

# Test 11: SSL Certificate (if HTTPS)
if curl -k -s https://$DOMAIN > /dev/null 2>&1; then
    run_test "HTTPS Certificate Valid" \
        "curl -f -s https://$DOMAIN > /dev/null" \
        "https working"
fi

# Test 12: Domain Resolution
run_test "Domain Resolution" \
    "nslookup $DOMAIN > /dev/null 2>&1" \
    "domain resolves"

# Test 13: Application Response Time
run_test "Response Time Acceptable" \
    "timeout 5 curl -w '%{time_total}' -s -o /dev/null http://localhost:$LOCAL_PORT/ | awk '{if(\$1 < 2.0) exit 0; else exit 1}'" \
    "< 2 seconds"

# Test 14: Error Rate Check
run_test "Low Error Rate" \
    "pm2 logs $SERVICE_NAME --lines 100 --nostream | grep -c 'ERROR' | awk '{if(\$1 < 5) exit 0; else exit 1}'" \
    "< 5 errors"

# Test 15: Build Files Present
run_test "Build Files Present" \
    "test -f dist/index.js -a -f dist/public/index.html" \
    "build files exist"

echo ""
echo "=================================================="
echo -e "${BLUE}📊 Test Results Summary${NC}"
echo "=================================================="
echo -e "Total Tests: $TESTS_TOTAL"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 ALL TESTS PASSED! Deployment is successful.${NC}"
    echo -e "${GREEN}✅ Your application is ready for production use.${NC}"
    echo ""
    echo -e "${BLUE}🌐 Application URLs:${NC}"
    echo "   • Main Site: https://$DOMAIN"
    echo "   • Admin Panel: https://$DOMAIN/admin"
    echo "   • Customer App: https://$DOMAIN/customer"
    echo "   • API Health: https://$DOMAIN/api/health"
    echo ""
    exit 0
else
    echo ""
    echo -e "${RED}⚠️  SOME TESTS FAILED! Please review and fix issues.${NC}"
    echo -e "${YELLOW}💡 Check the following:${NC}"
    echo "   • PM2 service status: pm2 status"
    echo "   • Application logs: pm2 logs $SERVICE_NAME"
    echo "   • System resources: free -h && df -h"
    echo "   • Network connectivity: netstat -tlnp"
    echo ""
    exit 1
fi