#!/usr/bin/env bash

DIRS=(
    "$HOME/go/src/neonpulse.io/modbusfirmwaremanager"
    "$HOME/go/src/neonpulse.io/modbustools"
)

for dir in "${DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "⚠  $dir — Verzeichnis nicht gefunden"
        echo
        continue
    fi

    echo "📁 $dir"

    cd "$dir" || continue

    # Uncommitted changes
    if ! git diff --quiet || ! git diff --cached --quiet; then
        echo "   → Uncommitted changes vorhanden"
    fi

    # Untracked files
    if [ -n "$(git ls-files --others --exclude-standard)" ]; then
        echo "   → Untracked files vorhanden"
    fi

    # Fetch remote changes (silently)
    git fetch --quiet 2>/dev/null

    # Commits to push (for each branch tracking a remote)
    UNPUSHED=$(git log --branches --not --remotes --oneline 2>/dev/null)
    if [ -n "$UNPUSHED" ]; then
        echo "   → Commits zum Pushen vorhanden:"
        echo "$UNPUSHED" | sed 's/^/      /'
    fi

    # Commits to pull (remote ahead of local)
    UNPULLED=$(git log --oneline HEAD..@{u} 2>/dev/null)
    if [ -n "$UNPULLED" ]; then
        echo "   → Commits auf dem Server (zum Pullen):"
        echo "$UNPULLED" | sed 's/^/      /'
    fi

    # Check if everything is clean
    if git diff --quiet && git diff --cached --quiet \
        && [ -z "$(git ls-files --others --exclude-standard)" ] \
        && [ -z "$UNPUSHED" ] \
        && [ -z "$UNPULLED" ]; then
        echo "   ✓ Alles sauber"
    fi

    echo
done
