#!/usr/bin/env bash
# validate-all.sh — Validates all skills in the monorepo
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Find package_skill.py using NPM_PREFIX env var (set by CI) or npm root
NPM_GLOBAL="${NPM_PREFIX:-$(npm root -g 2>/dev/null)}"
PKG_SCRIPT=""
for dir in \
    "$NPM_GLOBAL/openclaw/skills/skill-creator/scripts/package_skill.py" \
    "$HOME/.npm-global/lib/node_modules/openclaw/skills/skill-creator/scripts/package_skill.py" \
    "/usr/local/lib/node_modules/openclaw/skills/skill-creator/scripts/package_skill.py"; do
    if [ -f "$dir" ]; then
        PKG_SCRIPT="$dir"
        break
    fi
done

if [ -z "$PKG_SCRIPT" ]; then
    echo "❌ package_skill.py not found."
    echo "   NPM_PREFIX=$NPM_PREFIX"
    echo "   npm root -g=$(npm root -g)"
    echo "   Run: npm install -g openclaw"
    exit 1
fi

SKILLS_DIR="$REPO_ROOT/skills"
FAILED=0

echo "🔍 Validating skills in $SKILLS_DIR (using $PKG_SCRIPT)"

for skill in "$SKILLS_DIR"/*/; do
    skill_name="$(basename "$skill")"
    if [ -f "$skill/SKILL.md" ]; then
        echo -n "  $skill_name... "
        if python3 "$PKG_SCRIPT" "$skill" > /dev/null 2>&1; then
            echo "✅"
        else
            echo "❌"
            python3 "$PKG_SCRIPT" "$skill" 2>&1 | tail -2
            FAILED=$((FAILED + 1))
        fi
    fi
done

echo ""
if [ $FAILED -eq 0 ]; then
    echo "✅ All skills passed validation"
    exit 0
else
    echo "❌ $FAILED skill(s) failed"
    exit 1
fi
