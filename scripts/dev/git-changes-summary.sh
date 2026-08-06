#!/usr/bin/env bash

# GDSentry - Git Changes Summary
# Provides a comprehensive view of changes in the repository
#
# Usage:
#   ./git-changes-summary.sh [options]
#
# Options:
#   --staged         Show only staged changes
#   --commit <ref>   Compare against specific commit (default: HEAD)
#   --stats          Show detailed statistics
#   --full           Show full diffs
#   --files-only     Show only changed files list
#   --help           Show this help

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration
COMPARE_REF="HEAD"
SHOW_STAGED=false
SHOW_STATS=false
SHOW_FULL_DIFF=false
FILES_ONLY=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --staged)
            SHOW_STAGED=true
            shift
            ;;
        --commit)
            COMPARE_REF="$2"
            shift 2
            ;;
        --stats)
            SHOW_STATS=true
            shift
            ;;
        --full)
            SHOW_FULL_DIFF=true
            shift
            ;;
        --files-only)
            FILES_ONLY=true
            shift
            ;;
        --help)
            head -n 15 "$0" | tail -n 13
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Header
echo -e "${BOLD}${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${BLUE}║${NC}  ${BOLD}GDSentry - Git Changes Summary${NC}                              ${BOLD}${BLUE}║${NC}"
echo -e "${BOLD}${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Repository info
echo -e "${CYAN}Repository Information:${NC}"
echo -e "  Branch:  ${GREEN}$(git branch --show-current)${NC}"
echo -e "  Commit:  ${YELLOW}$(git rev-parse --short HEAD)${NC} - $(git log -1 --pretty=format:'%s')"
echo -e "  Author:  $(git log -1 --pretty=format:'%an <%ae>')"
echo -e "  Date:    $(git log -1 --pretty=format:'%ar (%ad)' --date=format:'%Y-%m-%d %H:%M')"
echo ""

if [ "$FILES_ONLY" = true ]; then
    echo -e "${CYAN}Changed Files:${NC}"
    if [ "$SHOW_STAGED" = true ]; then
        git diff --name-only --staged | sort
    else
        git status --short | awk '{print $2}' | sort
    fi
    exit 0
fi

# Summary of changes
echo -e "${CYAN}Change Summary:${NC}"

if [ "$SHOW_STAGED" = true ]; then
    echo -e "  ${YELLOW}[Showing staged changes only]${NC}"
    echo ""
    
    ADDED=$(git diff --cached --numstat | awk '{s+=$1} END {print s+0}')
    REMOVED=$(git diff --cached --numstat | awk '{s+=$2} END {print s+0}')
    FILES=$(git diff --cached --name-only | wc -l | xargs)
    
    echo -e "  Files changed:    ${BOLD}$FILES${NC}"
    echo -e "  Lines added:      ${GREEN}+$ADDED${NC}"
    echo -e "  Lines removed:    ${RED}-$REMOVED${NC}"
else
    # Unstaged + staged changes
    MODIFIED=$(git status --short | grep "^ M\|^M " | wc -l | xargs)
    ADDED=$(git status --short | grep "^A\|^??" | wc -l | xargs)
    DELETED=$(git status --short | grep "^ D\|^D " | wc -l | xargs)
    
    echo -e "  Modified:         ${YELLOW}$MODIFIED${NC}"
    echo -e "  Added:            ${GREEN}$ADDED${NC}"
    echo -e "  Deleted:          ${RED}$DELETED${NC}"
fi
echo ""

# File breakdown by category
echo -e "${CYAN}Changes by Category:${NC}"

if [ "$SHOW_STAGED" = true ]; then
    CHANGED_FILES=$(git diff --cached --name-only)
else
    CHANGED_FILES=$(git status --short | awk '{print $2}')
fi

# Count by file type using simple counters
python_count=0
gdscript_count=0
shell_count=0
markdown_count=0
rst_count=0
config_count=0
tests_count=0
docs_count=0
scripts_count=0
other_count=0

while IFS= read -r file; do
    if [[ -z "$file" ]]; then continue; fi
    
    if [[ "$file" == *.py ]]; then
        ((python_count++))
    elif [[ "$file" == *.gd ]]; then
        ((gdscript_count++))
    elif [[ "$file" == *.sh ]]; then
        ((shell_count++))
    elif [[ "$file" == *.md ]]; then
        ((markdown_count++))
    elif [[ "$file" == *.rst ]]; then
        ((rst_count++))
    elif [[ "$file" == *.toml ]] || [[ "$file" == *.yml ]] || [[ "$file" == *.yaml ]]; then
        ((config_count++))
    elif [[ "$file" == tests/* ]]; then
        ((tests_count++))
    elif [[ "$file" == docs/* ]]; then
        ((docs_count++))
    elif [[ "$file" == scripts/* ]]; then
        ((scripts_count++))
    else
        ((other_count++))
    fi
done <<< "$CHANGED_FILES"

# Display counts
if [ $python_count -gt 0 ]; then
    echo -e "  Python:            ${BOLD}$python_count${NC} files"
fi
if [ $gdscript_count -gt 0 ]; then
    echo -e "  GDScript:          ${BOLD}$gdscript_count${NC} files"
fi
if [ $shell_count -gt 0 ]; then
    echo -e "  Shell:             ${BOLD}$shell_count${NC} files"
fi
if [ $markdown_count -gt 0 ]; then
    echo -e "  Markdown:          ${BOLD}$markdown_count${NC} files"
fi
if [ $rst_count -gt 0 ]; then
    echo -e "  reStructuredText:  ${BOLD}$rst_count${NC} files"
fi
if [ $config_count -gt 0 ]; then
    echo -e "  Config:            ${BOLD}$config_count${NC} files"
fi
if [ $tests_count -gt 0 ]; then
    echo -e "  Tests:             ${BOLD}$tests_count${NC} files"
fi
if [ $docs_count -gt 0 ]; then
    echo -e "  Documentation:     ${BOLD}$docs_count${NC} files"
fi
if [ $scripts_count -gt 0 ]; then
    echo -e "  Scripts:           ${BOLD}$scripts_count${NC} files"
fi
if [ $other_count -gt 0 ]; then
    echo -e "  Other:             ${BOLD}$other_count${NC} files"
fi
echo ""

# Status output
echo -e "${CYAN}Detailed Status:${NC}"
if [ "$SHOW_STAGED" = true ]; then
    git diff --cached --stat
else
    git status --short
fi
echo ""

# Show statistics if requested
if [ "$SHOW_STATS" = true ]; then
    echo -e "${CYAN}Statistics:${NC}"
    if [ "$SHOW_STAGED" = true ]; then
        git diff --cached --stat
    else
        echo ""
        echo -e "${YELLOW}Staged changes:${NC}"
        if git diff --cached --quiet; then
            echo -e "  ${MAGENTA}(no staged changes)${NC}"
        else
            git diff --cached --stat
        fi
        
        echo ""
        echo -e "${YELLOW}Unstaged changes:${NC}"
        if git diff --quiet; then
            echo -e "  ${MAGENTA}(no unstaged changes)${NC}"
        else
            git diff --stat
        fi
    fi
    echo ""
fi

# Show full diff if requested
if [ "$SHOW_FULL_DIFF" = true ]; then
    echo -e "${CYAN}Full Diff:${NC}"
    echo -e "${YELLOW}────────────────────────────────────────────────────────────────${NC}"
    if [ "$SHOW_STAGED" = true ]; then
        git diff --cached --color=always
    else
        git diff --color=always HEAD
    fi
    echo -e "${YELLOW}────────────────────────────────────────────────────────────────${NC}"
    echo ""
fi

# Key changes detection
echo -e "${CYAN}Key Files Changed:${NC}"

KEY_FILES=(
    "pyproject.toml"
    "environment.yml"
    "gdsentry.toml"
    ".gitignore"
    "README.md"
    "CHANGELOG.md"
)

found_key_changes=false
for key_file in "${KEY_FILES[@]}"; do
    if echo "$CHANGED_FILES" | grep -q "^$key_file$"; then
        echo -e "  ${YELLOW}⚠${NC}  $key_file"
        found_key_changes=true
    fi
done

if [ "$found_key_changes" = false ]; then
    echo -e "  ${GREEN}✓${NC} No critical configuration files changed"
fi
echo ""

# Actionable suggestions
echo -e "${CYAN}Suggested Actions:${NC}"

if [ "$SHOW_STAGED" = false ]; then
    STAGED_COUNT=$(git diff --cached --name-only | wc -l | xargs)
    UNSTAGED_COUNT=$(git diff --name-only | wc -l | xargs)
    UNTRACKED_COUNT=$(git ls-files --others --exclude-standard | wc -l | xargs)
    
    if [ "$STAGED_COUNT" -gt 0 ]; then
        echo -e "  ${GREEN}→${NC} $STAGED_COUNT file(s) staged and ready to commit"
    fi
    
    if [ "$UNSTAGED_COUNT" -gt 0 ]; then
        echo -e "  ${YELLOW}→${NC} $UNSTAGED_COUNT file(s) modified but not staged"
        echo -e "     Run: ${BOLD}git add <file>${NC} to stage changes"
    fi
    
    if [ "$UNTRACKED_COUNT" -gt 0 ]; then
        echo -e "  ${CYAN}→${NC} $UNTRACKED_COUNT untracked file(s)"
        echo -e "     Run: ${BOLD}git add <file>${NC} to track, or add to .gitignore"
    fi
    
    if [ "$STAGED_COUNT" -eq 0 ] && [ "$UNSTAGED_COUNT" -eq 0 ] && [ "$UNTRACKED_COUNT" -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} Working tree clean - nothing to commit"
    fi
else
    echo -e "  ${GREEN}→${NC} Staged changes ready to commit"
    echo -e "     Run: ${BOLD}git commit -m 'Your message'${NC}"
fi

echo ""
echo -e "${CYAN}Quick Commands:${NC}"
echo -e "  View staged diff:     ${BOLD}git diff --cached${NC}"
echo -e "  View unstaged diff:   ${BOLD}git diff${NC}"
echo -e "  Stage all changes:    ${BOLD}git add -A${NC}"
echo -e "  Interactive staging:  ${BOLD}git add -p${NC}"
echo -e "  Commit changes:       ${BOLD}git commit${NC}"
echo ""
