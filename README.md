### I Asked Copilot To Create Bash Script
> I'm on linux and I'd like a bash shell script which will run git clone to retrieve all my github repos to my local. My github repo is https://github.com/raddevus/ and all my repos have varied names under that URL. Please write the script

#### Update Note
At first I just wanted it to clone all my projects, but I asked Copilot to make a slight change to take the GitHub `username` on the command line so it is a generic script that everyone can use.

### Copilot Reply
> Got it. Since you want to clone all repos under your GitHub account (raddevus), the cleanest way is to use the GitHub API to list them, then loop through and git clone each one.

> Here’s a bash script that does exactly that:

```
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
```

### Copilot's Script Details
#### 🔧 Requirements
curl (usually installed by default on Linux)

jq (JSON parser; install with sudo apt install jq or sudo dnf install jq depending on your distro)

⚡ How it works
Calls the GitHub REST API to list repos for raddevus.

Uses jq to extract the clone_url for each repo.

Loops through and clones them into ~/github-repos/raddevus/.

Skips repos that are already cloned locally.

Handles pagination (in case you have more than 100 repos).

👉 If you want to also include private repos, you’ll need to authenticate with a GitHub Personal Access Token (PAT). I can show you how to modify the script for that if you’d like.
