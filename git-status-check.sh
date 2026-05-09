#!/usr/bin/env bash

DO_PULL=false
if [[ "$1" == "--pull" ]]; then
    DO_PULL=true
fi

DIRS=(
    "$HOME/scripts"
    "$HOME/.scheduled"
    "$HOME/work/configurations"
    "$HOME/work/ralfwirdemann-hugo"
    "$HOME/go/src/github.com/rwirdemann/scheduled"
    "$HOME/go/src/neonpulse.io/firmwaremanager"
    "$HOME/go/src/neonpulse.io/modbustools"
    "$HOME/go/src/neonpulse.io/modbusappgo"
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

    # Commits to pull (remote ahead of local, per tracking branch)
    CURRENT_BRANCH=$(git branch --show-current)
    HAS_UNPULLED=false
    while read -r local upstream remote; do
        [ -z "$upstream" ] && continue
        COMMITS=$(git log "$local..$upstream" --oneline 2>/dev/null)
        [ -z "$COMMITS" ] && continue
        HAS_UNPULLED=true
        if $DO_PULL; then
            if [ "$local" = "$CURRENT_BRANCH" ]; then
                OUTPUT=$(git pull 2>&1)
                EXIT=$?
            else
                remote_branch=${upstream#"$remote"/}
                OUTPUT=$(git fetch "$remote" "$remote_branch:$local" 2>&1)
                EXIT=$?
            fi
            if [ $EXIT -eq 0 ]; then
                echo "   ✓ Gepullt ($local):"
            else
                echo "   ✗ Pull fehlgeschlagen ($local):"
            fi
            echo "$OUTPUT" | sed 's/^/      /'
        else
            echo "   → Commits zum Pullen ($local):"
            echo "$COMMITS" | sed 's/^/      /'
        fi
    done < <(git branch --format='%(refname:short) %(upstream:short) %(upstream:remotename)')

    # Check if everything is clean
    if git diff --quiet && git diff --cached --quiet \
        && [ -z "$(git ls-files --others --exclude-standard)" ] \
        && [ -z "$UNPUSHED" ] \
        && ! $HAS_UNPULLED; then
        echo "   ✓ Alles sauber"
    fi

    echo
done
