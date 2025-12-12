#!/usr/bin/env bash

# Post-create script for D3-Kit development container

set -e

echo "Setting up D3-Kit development environment..."

# Install uv if not already installed
if ! command -v uv &> /dev/null; then
    echo "Installing uv..."
    python -m pip install uv
fi

# Install D3-Kit in development mode
echo "Installing D3-Kit in development mode..."
cd /workspaces/D3-Kit
python -m pip install -e .

# Install additional development tools
python -m pip install pytest black flake8 mypy

# Setup git configuration for development
if [ -n "$GITHUB_USER_NAME" ]; then
    git config --global user.name "$GITHUB_USER_NAME"
fi
if [ -n "$GITHUB_USER_EMAIL" ]; then
    git config --global user.email "$GITHUB_USER_EMAIL"
fi

# Set up git aliases for D3-Kit workflow
git config --global alias.d3 '!d3 create-new-feature.sh'
git config --global alias.d3-check '!d3 check-prerequisites.sh'

echo "D3-Kit development environment setup complete!"
echo ""
echo "Available tools:"
echo "- d3 CLI tool for project initialization and command templates"
echo "- Python 3.11 with development packages"
echo "- Git configured for D3-Kit workflows"