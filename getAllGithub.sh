#!/bin/bash

# Check if username was provided
if [ -z "$1" ]; then
    echo "Error: No GitHub username provided."
    echo "Usage: $0 <github-username>"
    exit 1
fi

USER="$1"

# Directory where repos will be cloned
DEST_DIR="$HOME/github-repos/$USER"
mkdir -p "$DEST_DIR"
cd "$DEST_DIR" || exit 1

# Repos to exclude (edit this list manually)
EXCLUDE_REPOS=("apps" "to-skip-2")

# Function to check if a repo is in the exclusion list
is_excluded() {
    local name="$1"
    for exclude in "${EXCLUDE_REPOS[@]}"; do
        if [[ "$name" == "$exclude" ]]; then
            return 0
        fi
    done
    return 1
}

# Fetch all repos (handles pagination too)
page=1
while : ; do
    repos=$(curl -s "https://api.github.com/users/$USER/repos?per_page=100&page=$page" | jq -r '.[].clone_url')
    
    # Break if no more repos
    [ -z "$repos" ] && break

    for repo in $repos; do
        reponame=$(basename "$repo" .git)

	if is_excluded "$reponame"; then
            echo "Skipping $reponame (excluded)"
            continue
        fi

        if [ -d "$reponame" ]; then
         echo "Updating $reponame ..."
         (cd "$reponame" && git pull --ff-only)
        else
            echo "Cloning $repo ..."
            git clone "$repo"
        fi
    done

    page=$((page+1))
done

