#!/bin/bash

# ==============================================================================
# Script Name: setup-macos.sh
# Description: Automates the setup of a macOS development environment
#              by installing and configuring programming languages,
#              development tools, and applications using Homebrew and Mise,
#              updating environment variables, modifying the /etc/hosts file,
#              and downloading necessary files
# Author: Dimas Yudha Pratama <ping@dimasyudha.com>
# Date: Nov 22th, 2024
# ==============================================================================

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# ==============================================================================
# Define Package Versions
# ------------------------------------------------------------------------------
# Store all hardcoded package versions in dedicated variables for easy updates
# ==============================================================================

JAVA_CORRETTO_21_VERSION="21.0.5.11.1"
JAVA_CORRETTO_17_VERSION="17.0.13.11.1"
JAVA_GRAALVM_VERSION="21.0.2"
RUST_VERSION="1.82.0"
KOTLIN_VERSION="2.0.21"
BUN_VERSION="1.1.36"
YARN_VERSION="4.5.2"
PNPM_VERSION="9.14.2"
GRADLE_VERSION="8.11.1"
MAVEN_VERSION="3.9.9"
ZIG_VERSION="0.13.0"
FLUTTER_VERSION="3.24.5-stable"
KUBECTL_VERSION="1.29.11"
RCLONE_VERSION="1.68.2"
PYTHON_VERSION="3.13.0"
NODEJS_VERSION="23.3.0"
HELM_VERSION="3.16.3"
GCLOUD_VERSION="502.0.0"

# ==============================================================================
# Define Download URLs
# ------------------------------------------------------------------------------
# Store download URLs in variables for easy management and updates
# ==============================================================================

MOBAXTERM_URL="https://download.mobatek.net/2432024101610907/MobaXterm_Installer_v24.3_Preview5.zip"
GAME_PORTING_TOOLKIT_URL="https://download.developer.apple.com/Developer_Tools/Game_porting_toolkit_beta/Game_Porting_Toolkit_2.0_beta_3.dmg"
XCODE_URL="https://download.developer.apple.com/Developer_Tools/Xcode_16.2_beta_3/Xcode_16.2_beta_3.xip"
CROSSOVER_URL="https://www.codeweavers.com/preview/download/crossover-preview-20241028.zip"

# ==============================================================================
# Function Definitions
# ------------------------------------------------------------------------------
# Define functions for informational and error messages to enhance readability
# ==============================================================================

# Function to display informational messages
info() {
    echo -e "\033[1;32m[INFO]\033[0m $*"
}

# Function to display error messages
error() {
    echo -e "\033[1;31m[ERROR]\033[0m $*" >&2
}

# ==============================================================================
# Update PATH Environment Variable
# ------------------------------------------------------------------------------
# Prepend necessary directories to the PATH environment variable for tool access
# ==============================================================================

info "Updating PATH environment variable"
export PATH="$HOME/.local/share/mise/shims:/opt/homebrew/bin:$PATH"

# ==============================================================================
# Append Environment Variables to .zshrc
# ------------------------------------------------------------------------------
# Configure environment variables and append them to the .zshrc file for future
# shell sessions
# ==============================================================================

info "Appending environment variables to $HOME/.zshrc"
{
    echo 'export PATH="$HOME/.local/share/mise/shims:/opt/homebrew/bin:$PATH"'
    echo 'export ANDROID_HOME="$HOME/Android/Sdk"'
    echo 'export NDK_HOME="$ANDROID_HOME/ndk/$(ls -1 $ANDROID_HOME/ndk)"'
    echo 'export JAVA_HOME="$HOME/.local/share/mise/installs/java/${JAVA_CORRETTO_21_VERSION}"'
    echo 'export CHROME_EXECUTABLE="/Applications/Arc.app/Contents/MacOS/Arc"'
    echo 'export VISUAL="nano"'
    echo 'export EDITOR="nano"'
} >> "$HOME/.zshrc" || { error "Failed to append to $HOME/.zshrc"; exit 1; }

# ==============================================================================
# Update /etc/hosts File
# ------------------------------------------------------------------------------
# Add necessary host entries to the /etc/hosts file to resolve domain names
# ==============================================================================

info "Updating /etc/hosts file with necessary entries"

HOSTS_CONTENT=$(cat <<EOF
151.101.129.140   i.redditmedia.com
52.34.230.181     www.reddithelp.com
151.101.65.140    g.redditmedia.com
151.101.65.140    a.thumbs.redditmedia.com
151.101.1.140     redditgifts.com
151.101.1.140     i.redd.it
151.101.1.140     old.reddit.com
151.101.1.140     new.reddit.com
151.101.129.140   reddit.com
151.101.129.140   gateway.reddit.com
151.101.129.140   oauth.reddit.com
151.101.129.140   sendbird.reddit.com
151.101.129.140   v.redd.it
151.101.1.140     b.thumbs.redditmedia.com
151.101.1.140     events.reddit.com
54.210.123.98     stats.redditmedia.com
151.101.65.140    www.redditstatic.com
151.101.193.140   www.reddit.com
52.3.23.26        pixel.redditmedia.com
151.101.65.140    www.redditmedia.com
151.101.193.140   about.reddit.com
151.101.1.140     out.reddit.com
107.23.236.34     events.redditmedia.com
151.101.61.140    e.reddit.com
151.101.197.140   s.redditmedia.com
146.75.25.140     gql.reddit.com
151.101.1.140     alb.reddit.com
34.207.103.54     sendbirdproxy-06490ff42851cbcc5.chat.redditmedia.com
52.207.213.188    sendbirdproxy-003d8d1fb8653f6f8.chat.redditmedia.com
34.226.121.89     sendbirdproxy-04ea6c3f71aac3e3f.chat.redditmedia.com
EOF
)

if ! echo "$HOSTS_CONTENT" | sudo tee -a /etc/hosts >/dev/null; then
    error "Failed to update /etc/hosts"

    exit 1
fi

# ==============================================================================
# Install Homebrew
# ------------------------------------------------------------------------------
# Install Homebrew package manager if it's not already installed
# ==============================================================================

if ! command -v brew &>/dev/null; then
    info "Installing Homebrew"

    if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        error "Failed to install Homebrew"

        exit 1
    fi
else
    info "Homebrew is already installed"
fi

# ==============================================================================
# Install Brew Cask Packages
# ------------------------------------------------------------------------------
# Install GUI applications using Homebrew Cask
# ==============================================================================

BREW_CASK_PACKAGES=(
    cursor
    dbeaver-enterprise
    insomnia
    warp
    figma
    notion
    arc
    raycast
    whatsapp
    notchnook
    chatgpt
    docker
    android-studio
    microsoft-office
    discord
)

info "Installing brew cask packages"

for package in "${BREW_CASK_PACKAGES[@]}"; do
    if ! brew list --cask "$package" &>/dev/null; then
        info "Installing $package via brew cask"

        if ! brew install --cask "$package"; then
            error "Failed to install $package via brew cask"

            exit 1
        fi
    else
        info "$package is already installed"
    fi
done

# ==============================================================================
# Install Brew Packages
# ------------------------------------------------------------------------------
# Install command-line tools using Homebrew
# ==============================================================================

BREW_PACKAGES=(
    mise
    cocoapods
)

info "Installing brew packages"

for package in "${BREW_PACKAGES[@]}"; do
    if ! brew list "$package" &>/dev/null; then
        info "Installing $package via brew"

        if ! brew install "$package"; then
            error "Failed to install $package via brew"

            exit 1
        fi
    else
        info "$package is already installed"
    fi
done

# ==============================================================================
# Install Packages with Mise
# ------------------------------------------------------------------------------
# Use 'mise' to install specific versions of programming languages and tools
# ==============================================================================

MISE_PACKAGES=(
    "java@corretto-${JAVA_CORRETTO_21_VERSION}"
    "java@corretto-${JAVA_CORRETTO_17_VERSION}"
    "java@graalvm-community-${JAVA_GRAALVM_VERSION}"
    "rust@${RUST_VERSION}"
    "kotlin@${KOTLIN_VERSION}"
    "bun@${BUN_VERSION}"
    "yarn@${YARN_VERSION}"
    "pnpm@${PNPM_VERSION}"
    "gradle@${GRADLE_VERSION}"
    "maven@${MAVEN_VERSION}"
    "zig@${ZIG_VERSION}"
    "flutter@${FLUTTER_VERSION}"
    "kubectl@${KUBECTL_VERSION}"
    "rclone@${RCLONE_VERSION}"
    "python@${PYTHON_VERSION}"
    "nodejs@${NODEJS_VERSION}"
    "helm@${HELM_VERSION}"
    "gcloud@${GCLOUD_VERSION}"
)

info "Installing packages with mise"

for package in "${MISE_PACKAGES[@]}"; do
    if ! mise list | grep -q "$package"; then
        info "Installing $package with mise"

        if ! mise install "$package"; then
            error "Failed to install $package with mise"

            exit 1
        fi
    else
        info "$package is already installed with mise"
    fi
done

# ==============================================================================
# Set Global Versions with Mise
# ------------------------------------------------------------------------------
# Set default global versions for tools installed with 'mise'
# ==============================================================================

MISE_GLOBAL_PACKAGES=(
    "java@corretto-${JAVA_CORRETTO_21_VERSION}"
    "rust@${RUST_VERSION}"
    "kotlin@${KOTLIN_VERSION}"
    "bun@${BUN_VERSION}"
    "yarn@${YARN_VERSION}"
    "pnpm@${PNPM_VERSION}"
    "gradle@${GRADLE_VERSION}"
    "maven@${MAVEN_VERSION}"
    "zig@${ZIG_VERSION}"
    "flutter@${FLUTTER_VERSION}"
    "kubectl@${KUBECTL_VERSION}"
    "rclone@${RCLONE_VERSION}"
    "python@${PYTHON_VERSION}"
    "nodejs@${NODEJS_VERSION}"
    "helm@${HELM_VERSION}"
    "gcloud@${GCLOUD_VERSION}"
)

info "Setting global versions with mise"

if ! mise global "${MISE_GLOBAL_PACKAGES[@]}"; then
    error "Failed to set global versions with mise"

    exit 1
fi

# ==============================================================================
# Download Files with Curl
# ------------------------------------------------------------------------------
# Download necessary files using curl and save them to the Downloads directory
# ==============================================================================

DOWNLOADS=(
    "$MOBAXTERM_URL"
    "$GAME_PORTING_TOOLKIT_URL"
    "$XCODE_URL"
    "$CROSSOVER_URL"
)

DOWNLOAD_DIR="$HOME/Downloads"
mkdir -p "$DOWNLOAD_DIR"

info "Downloading files with curl"

for url in "${DOWNLOADS[@]}"; do
    filename="${url##*/}"

    if [ -f "$DOWNLOAD_DIR/$filename" ]; then
        info "$filename already exists in $DOWNLOAD_DIR"
    else
        info "Downloading $filename"

        if ! curl -L "$url" -o "$DOWNLOAD_DIR/$filename"; then
            error "Failed to download $filename"

            exit 1
        fi
    fi
done

# ==============================================================================
# Completion Message
# ------------------------------------------------------------------------------
# Indicate that the script has completed successfully
# ==============================================================================

info "Script completed successfully!"