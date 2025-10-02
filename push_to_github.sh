#!/bin/bash
# Script to help push Speech Translation System to GitHub
# This is a helper script - review commands before running

echo "================================================================================"
echo "  Speech Translation System - GitHub Push Helper"
echo "================================================================================"
echo ""
echo "This script will help you push the project to your GitHub repository."
echo ""
echo "⚠️  IMPORTANT: Read this first!"
echo ""
echo "1. Create a repository on GitHub first:"
echo "   - Go to: https://github.com/new"
echo "   - Name: speech-translation-system (or your choice)"
echo "   - DO NOT initialize with README"
echo ""
echo "2. You'll need:"
echo "   - Your GitHub username"
echo "   - Your repository name"
echo "   - A Personal Access Token (https://github.com/settings/tokens)"
echo ""
echo "================================================================================"
echo ""

# Get user input
read -p "Enter your GitHub username: " GITHUB_USER
read -p "Enter your repository name: " REPO_NAME

echo ""
echo "Will push to: https://github.com/$GITHUB_USER/$REPO_NAME"
echo ""
read -p "Is this correct? (y/n): " CONFIRM

if [ "$CONFIRM" != "y" ]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "================================================================================"
echo "  Executing Git Commands"
echo "================================================================================"
echo ""

# Add remote
echo "→ Adding remote repository..."
git remote add myrepo "https://github.com/$GITHUB_USER/$REPO_NAME.git" 2>/dev/null || \
git remote set-url myrepo "https://github.com/$GITHUB_USER/$REPO_NAME.git"

# Add files
echo "→ Adding files to git..."
git add .

# Check status
echo ""
echo "→ Files to be committed:"
git status --short

# Commit
echo ""
read -p "Ready to commit? (y/n): " COMMIT_CONFIRM
if [ "$COMMIT_CONFIRM" = "y" ]; then
    git commit -m "Add complete Speech Translation System

Complete real-time speech translation system with:
- Whisper AI transcription service
- Argos Translate translation service  
- n8n workflow orchestration
- Beautiful web interface with recording and upload
- 20+ language support
- Complete documentation (83 pages)
- Setup automation scripts
- 100% local, no cloud services
- Microsoft Surface optimized
- Production ready"
    
    echo ""
    echo "✓ Files committed"
else
    echo "Commit skipped. Run 'git commit -m \"message\"' manually."
    exit 0
fi

# Push
echo ""
echo "→ Pushing to GitHub..."
echo ""
echo "⚠️  When prompted for password, use your Personal Access Token"
echo ""
git push myrepo HEAD:main

if [ $? -eq 0 ]; then
    echo ""
    echo "================================================================================"
    echo "  ✓ SUCCESS! Project pushed to GitHub"
    echo "================================================================================"
    echo ""
    echo "View at: https://github.com/$GITHUB_USER/$REPO_NAME"
    echo ""
    echo "Next steps:"
    echo "  1. Go to your repository on GitHub"
    echo "  2. Add description and topics"
    echo "  3. Consider adding a license"
    echo "  4. Share with the world!"
    echo ""
else
    echo ""
    echo "================================================================================"
    echo "  ✗ Push failed"
    echo "================================================================================"
    echo ""
    echo "Common fixes:"
    echo "  - Make sure you used Personal Access Token, not password"
    echo "  - Verify repository exists on GitHub"
    echo "  - Check internet connection"
    echo ""
    echo "Try manually:"
    echo "  git push myrepo HEAD:main"
    echo ""
fi
