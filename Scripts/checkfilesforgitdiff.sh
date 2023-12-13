#!/bin/bash
# To implement an automated way in DevOps pipelines that blocks a pull request (PR) if it includes commits or changes to specific files, you can use a feature known as "branch policies" or "pull request policies" depending on your DevOps platform (e.g., Azure DevOps, GitHub Actions, GitLab CI/CD). These policies can be configured to enforce certain rules before a PR can be merged.

# Here's a general approach for setting up such a policy:
# Using Azure DevOps

#     Branch Policies:
#         Go to your Azure DevOps project.
#         Navigate to the 'Repos' section and then to 'Branches'.
#         Select the branch you want to protect.
#         Click on 'Branch policies'.
#         Add a 'Build Validation' policy.
#         In the build validation policy, you can specify a build pipeline that includes a script to check for changes in specific files.

#     Implementing the Script:
#         In your build pipeline, include a script (PowerShell, Bash, etc.) that checks for changes in the specified files.
#         If changes are detected, the script should exit with a non-zero status code. This will cause the build to fail and block the PR.

# Using GitHub Actions

#     Create a Workflow:
#         In your repository, create a new workflow under .github/workflows/.
#         Define a workflow that triggers on pull requests.

#     Implementing the Script:
#         In the workflow, include a job that checks out the code and runs a script to detect changes in the specific files.
#         Use git diff or similar commands to check for changes in the target files.
#         If changes are found, use exit 1 or similar to fail the workflow.

# Sample Script for Checking File Changes

# Here’s a basic example of what the script could look like in Bash:
# List of files to check
FILES_TO_CHECK=("file1.txt" "directory/file2.js")

# Function to check if a file is in the list of changed files
file_in_array() {
    local file=$1
    for i in "${FILES_TO_CHECK[@]}"; do
        if [[ $i == $file ]]; then
            return 0
        fi
    done
    return 1
}

# Get the list of changed files
CHANGED_FILES=$(git diff --name-only HEAD $(git merge-base HEAD master))

# Check each changed file
for file in $CHANGED_FILES; do
    if file_in_array $file; then
        echo "Error: PR contains changes to restricted file: $file"
        exit 1
    fi
done

echo "No restricted files changed."
