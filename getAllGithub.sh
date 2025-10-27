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

# Fetch all repos (handles pagination too)
page=1
while : ; do
    repos=$(curl -s "https://api.github.com/users/$USER/repos?per_page=100&page=$page" | jq -r '.[].clone_url')
    
    # Break if no more repos
    [ -z "$repos" ] && break

    for repo in $repos; do
        reponame=$(basename "$repo" .git)
        if [ -d "$reponame" ]; then
            echo "Skipping $reponame (already exists)"
        else
            echo "Cloning $repo ..."
            git clone "$repo"
        fi
    done

    page=$((page+1))
done

