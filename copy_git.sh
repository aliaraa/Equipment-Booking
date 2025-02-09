#!/bin/bash


# Array of branches to process (you can customize this)
branches=("main" "config" "authentication" "Categories" "development") # Add all your branches

# Source branch (the branch with the correct .gitignore)
source_branch="profile-settings"

for branch in "${branches[@]}"; do
  branch=$(echo "$branch" | tr -d ' ')  # Remove leading/trailing spaces

  git checkout "$branch" --force  # Force checkout to overwrite .gitignore

  if [ -f ".gitignore" ]; then
    rm .gitignore # Remove .gitignore if it exists on the target branch
  fi

  git checkout "$source_branch" -- .gitignore # copy .gitignore from source branch

  git add .gitignore  # Stage the .gitignore file
  git commit -m "Updated .gitignore from $source_branch"

done

git checkout main  # Switch back to your main branch