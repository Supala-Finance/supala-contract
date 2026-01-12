#!/bin/bash
# Pre-push CI simulation script
# This script runs the same checks as GitHub Actions CI locally

set -e  # Exit on any error

echo "🧹 Step 1: Cleaning build artifacts..."
forge clean

echo ""
echo "📝 Step 2: Checking code formatting..."
if forge fmt --check; then
    echo "✅ Code formatting is correct"
else
    echo "❌ Code formatting issues found. Run 'forge fmt' to fix."
    exit 1
fi

echo ""
echo "🔍 Step 3: Checking case sensitivity (Linux CI compatibility)..."
CASE_ERRORS=0

# Check if git-tracked filenames match actual filesystem casing
# This catches issues where macOS (case-insensitive) allows mismatches that fail on Linux (case-sensitive)
while IFS= read -r git_file; do
    if [ -f "$git_file" ]; then
        # Get the actual filesystem path by finding the file with case-insensitive match
        dir=$(dirname "$git_file")
        base=$(basename "$git_file")
        
        # Use -iname for case-insensitive search, then compare with git's casing
        actual=$(find "$dir" -maxdepth 1 -iname "$base" -type f 2>/dev/null | head -1)
        
        if [ -n "$actual" ]; then
            actual_relative="${actual#./}"
            git_relative="${git_file#./}"
            
            if [ "$git_relative" != "$actual_relative" ]; then
                echo "❌ Case mismatch detected:"
                echo "   Git tracks: $git_file"
                echo "   Filesystem: $actual"
                echo "   Fix: git mv '$git_file' 'temp_rename.sol' && git mv 'temp_rename.sol' '$actual'"
                CASE_ERRORS=$((CASE_ERRORS + 1))
            fi
        fi
    fi
done < <(git ls-files '*.sol')

if [ $CASE_ERRORS -gt 0 ]; then
    echo ""
    echo "❌ Found $CASE_ERRORS case sensitivity issue(s) that will fail on Linux CI."
    exit 1
else
    echo "✅ No case sensitivity issues found"
fi

echo ""
echo "📦 Step 4: Verifying dependencies..."
echo ""
echo "Git Submodules Status:"
echo "┌─────────────────────────────────────────────────────────────────────────────────┐"

# Get detailed submodule info
git submodule foreach --quiet '
    # Get the submodule name
    name=$(basename "$sm_path")
    
    # Get current commit
    commit=$(git rev-parse --short HEAD)
    
    # Get tag if exists (suppress errors)
    tag=$(git describe --tags --exact-match 2>/dev/null || echo "")
    
    # Get closest tag or branch info
    if [ -z "$tag" ]; then
        describe=$(git describe --tags --always 2>/dev/null || echo "$commit")
    else
        describe="$tag"
    fi
    
    # Get remote URL
    remote_url=$(git config --get remote.origin.url 2>/dev/null | sed "s|https://github.com/||" | sed "s|.git$||" || echo "unknown")
    
    printf "│ %-35s │ %-12s │ %-25s │\n" "$name" "$commit" "$describe"
'

echo "└─────────────────────────────────────────────────────────────────────────────────┘"
echo ""

# Verify required submodules exist
MISSING_DEPS=0

check_submodule() {
    local path=$1
    local name=$2
    if [ -d "$path" ]; then
        echo "✅ $name found"
    else
        echo "❌ $name not found. Run 'git submodule update --init --recursive'"
        MISSING_DEPS=$((MISSING_DEPS + 1))
    fi
}

check_submodule "lib/LayerZero-v2" "LayerZero-v2"
check_submodule "lib/openzeppelin-contracts-upgradeable" "openzeppelin-contracts-upgradeable"
check_submodule "lib/openzeppelin-contracts" "openzeppelin-contracts"
check_submodule "lib/devtools" "devtools"
check_submodule "lib/forge-std" "forge-std"

if [ $MISSING_DEPS -gt 0 ]; then
    exit 1
fi

echo ""
echo "🔨 Step 5: Building project..."
forge build --sizes

echo ""
echo "🧪 Step 6: Running tests (ProtocolTest only - no RPC required)..."
forge test -vv --match-contract "ProtocolTest" --no-match-test "testExecuteBuyback"

echo ""
echo "✅ =============================================="
echo "✅ All checks passed! Safe to push to GitHub."
echo "✅ =============================================="

