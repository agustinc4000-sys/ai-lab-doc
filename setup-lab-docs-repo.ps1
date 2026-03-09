# setup-lab-docs-repo.ps1
# Run ONCE on Windows laptop to create local git repo and push to GitHub
#
# PREREQUISITES:
#   - Git for Windows installed: https://git-scm.com/download/win
#   - GitHub private repo named: ai-lab-docs (no README, no .gitignore)
#   - GitHub Personal Access Token (classic) with repo scope
#
# USAGE:
#   1. Edit the four variables below
#   2. Open PowerShell in this folder
#   3. Run: .\setup-lab-docs-repo.ps1

# CONFIGURATION - edit these before running
$GITHUB_USERNAME = "agustinc4000-sys"
$REPO_NAME       = "ai-lab-doc"
$GIT_EMAIL       = "agustinc4000@gmail.com"
$GIT_NAME        = "Agustin"

$LOCAL_PATH = $PSScriptRoot
$REMOTE_URL = "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"

Write-Host ""
Write-Host "=== AI Lab Docs - GitHub Repository Setup ===" -ForegroundColor Cyan
Write-Host "Local path : $LOCAL_PATH"
Write-Host "GitHub     : $REMOTE_URL"
Write-Host ""

Set-Location $LOCAL_PATH

# Init repo
if (-not (Test-Path ".git")) {
    Write-Host "Initialising git repository..." -ForegroundColor Yellow
    git init
    git config user.email $GIT_EMAIL
    git config user.name $GIT_NAME
} else {
    Write-Host "Git repository already initialised." -ForegroundColor Green
}

# .gitignore
Write-Host "Creating .gitignore..." -ForegroundColor Yellow
$gitignore = @(
    "# OS",
    ".DS_Store",
    "Thumbs.db",
    "desktop.ini",
    "",
    "# Editor temp files",
    "*.tmp",
    "/archive/"
)
$gitignore | Set-Content ".gitignore" -Encoding UTF8

# Folder structure
Write-Host "Creating folder structure..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "session-framework\sessions" | Out-Null
New-Item -ItemType Directory -Force -Path "session-framework\scripts"  | Out-Null
New-Item -ItemType Directory -Force -Path "archive"                    | Out-Null

# README
Write-Host "Creating README.md..." -ForegroundColor Yellow
$readme = @(
    "# AI Lab Docs",
    "",
    "Reference documents for the AI Lab - KVM/VFIO homelab with GPU passthrough,",
    "Ollama inference server, and agentic AI workspace.",
    "",
    "## Documents",
    "",
    "| Document | Version | Purpose |",
    "|---|---|---|",
    "| Lab_Implementation_Checklist | v1.8 | Pending tasks with step-by-step commands |",
    "| AI_Lab_VM_Maintenance_Guide | v1.3 | Operational reference and SSH architecture |",
    "| AI_Lab_Implementation_Plan | v2.9 | Full build history and decisions |",
    "| Claude_AI_Work_Approach | v1.1 | Two-lane session system and RCD framework |",
    "| AI_Session_Prompts | v1.0 | Copy-paste prompts for every session stage |",
    "| build-scripts-manifest | - | Architecture for document build scripts |",
    "",
    "## Session Framework",
    "",
    "session-framework/sessions/rcd-template.md - RCD template",
    "session-framework/scripts/new-session - session creation script (deploy to VM)",
    "",
    "## Sync",
    "",
    "VM path: ~/workspace/knowledge/lab-docs/",
    "IronWolf backup: /mnt/ai_models/git/lab-docs.git"
)
$readme | Set-Content "README.md" -Encoding UTF8

# Stage and commit
Write-Host ""
Write-Host "Staging all files..." -ForegroundColor Yellow
git add .
git status

Write-Host ""
Write-Host "Creating initial commit..." -ForegroundColor Yellow
git commit -m "init: lab docs v1.8/v1.3/v2.9 - initial repository"

# Set main branch
git branch -M main

# Add remote
Write-Host ""
Write-Host "Adding GitHub remote: $REMOTE_URL" -ForegroundColor Yellow
$existing = git remote
if ($existing -contains "origin") {
    git remote set-url origin $REMOTE_URL
} else {
    git remote add origin $REMOTE_URL
}

# Push
Write-Host ""
Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
Write-Host "When prompted:" -ForegroundColor Cyan
Write-Host "  Username: your GitHub username" -ForegroundColor Cyan
Write-Host "  Password: your Personal Access Token (not your GitHub password)" -ForegroundColor Cyan
Write-Host ""
git push -u origin main

Write-Host ""
Write-Host "=== Done ===" -ForegroundColor Green
Write-Host "Repository: https://github.com/$GITHUB_USERNAME/$REPO_NAME" -ForegroundColor Green
Write-Host ""
Write-Host "Next step - copy setup-vm-sync.sh to the VM:" -ForegroundColor Cyan
Write-Host "  scp setup-vm-sync.sh vm:~/" -ForegroundColor Cyan
