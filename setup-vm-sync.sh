#!/bin/bash
# setup-vm-sync.sh
# Run ONCE on the VM as ailab to:
# 1. Create lab-docs directory in workspace
# 2. Clone from GitHub into it
# 3. Add the IronWolf bare repo as a second remote (optional local backup)
# 4. Configure git identity if not already set
#
# PREREQUISITES:
#   - GitHub repo already created and populated (run setup-lab-docs-repo.ps1 first)
#   - GitHub SSH key configured on VM (or use HTTPS with PAT)
#   - Run as ailab inside VM
#
# USAGE:
#   chmod +x setup-vm-sync.sh
#   ./setup-vm-sync.sh

# ── CONFIGURATION — edit before running ──────────────────────────────────────
GITHUB_USERNAME="YOUR_GITHUB_USERNAME"
REPO_NAME="ai-lab-docs"
GIT_EMAIL="YOUR_EMAIL@example.com"
GIT_NAME="YOUR_NAME"
WORKSPACE=~/workspace/knowledge
IRONWOLF_BARE=/mnt/ai_models/git/lab-docs.git
# ─────────────────────────────────────────────────────────────────────────────

echo ""
echo "=== AI Lab Docs — VM Sync Setup ==="
echo "GitHub : https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo "Local  : $WORKSPACE/lab-docs"
echo ""

# Configure git identity if not set
if [ -z "$(git config --global user.email)" ]; then
    echo "Configuring git identity..."
    git config --global user.email "$GIT_EMAIL"
    git config --global user.name "$GIT_NAME"
    git config --global init.defaultBranch main
    git config --global core.editor nano
fi

# Create workspace/knowledge if it doesn't exist yet
mkdir -p "$WORKSPACE"

# Clone from GitHub
CLONE_PATH="$WORKSPACE/lab-docs"
if [ -d "$CLONE_PATH/.git" ]; then
    echo "Repository already exists at $CLONE_PATH"
    echo "Pulling latest..."
    cd "$CLONE_PATH"
    git pull origin main
else
    echo "Cloning from GitHub..."
    git clone "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git" "$CLONE_PATH"
    cd "$CLONE_PATH"
fi

# Create bare repo on IronWolf for local backup (optional but recommended)
if [ ! -d "$IRONWOLF_BARE" ]; then
    echo ""
    echo "Creating bare repo on IronWolf at $IRONWOLF_BARE..."
    sudo mkdir -p "$IRONWOLF_BARE"
    sudo git init --bare "$IRONWOLF_BARE"
    sudo chown -R ailab:ailab "$IRONWOLF_BARE"
    echo "Adding IronWolf as 'backup' remote..."
    git remote add backup "ssh://ailab@192.168.1.31/$IRONWOLF_BARE"
else
    echo "IronWolf bare repo already exists."
fi

# Show remotes
echo ""
echo "Git remotes configured:"
git remote -v

# Show current state
echo ""
echo "Current files:"
ls -la

echo ""
echo "=== Done ==="
echo ""
echo "Daily workflow:"
echo "  Pull latest from GitHub : git pull origin main"
echo "  Push changes to GitHub  : git push origin main"
echo "  Push to IronWolf backup : git push backup main"
echo ""
echo "After updating a document from a Claude.ai session:"
echo "  cp ~/Downloads/Lab_Implementation_Checklist_v1.8.docx $CLONE_PATH/"
echo "  cd $CLONE_PATH"
echo "  git add ."
echo "  git commit -m 'docs: checklist v1.8 — description of changes'"
echo "  git push origin main"
