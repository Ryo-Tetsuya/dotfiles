#!/usr/bin/env bash

set -euo pipefail

readonly xcode_cli_tools_marker="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
sudo_keepalive_pid=""

cleanup_xcode_setup() {
    if [[ -n "$sudo_keepalive_pid" ]]; then
        kill "$sudo_keepalive_pid" 2>/dev/null || true
    fi
    rm -f "$xcode_cli_tools_marker"
}

run_sudo() {
    if [[ "${EUID}" -eq 0 ]]; then
        "$@"
    else
        sudo "$@"
    fi
}

request_sudo_for_xcode_setup() {
    if [[ "${EUID}" -ne 0 ]]; then
        echo "Requesting sudo access for Xcode setup..."
        sudo -v
        while true; do
            sudo -n true
            sleep 60
            kill -0 "$$" || exit
        done 2>/dev/null &
        sudo_keepalive_pid=$!
    fi
}

install_xcode_cli_tools() {
    echo "Installing Xcode Command Line Tools..."
    touch "$xcode_cli_tools_marker"

    local xcode_command_line_tools
    xcode_command_line_tools=$(/usr/sbin/softwareupdate --list 2>&1 | \
        /usr/bin/awk -F: '/Label: Command Line Tools for Xcode/ {print $NF}' | \
        /usr/bin/sed 's/^ *//' | \
        /usr/bin/tail -1)

    if [[ -z "$xcode_command_line_tools" ]]; then
        echo "Unable to find Xcode Command Line Tools in softwareupdate."
        exit 1
    fi

    run_sudo /usr/sbin/softwareupdate --install "$xcode_command_line_tools" --agree-to-license
}

accept_xcode_license() {
    if ! command -v xcodebuild >/dev/null 2>&1; then
        echo "xcodebuild not found; skipping Xcode license acceptance."
        return
    fi

    local developer_dir
    developer_dir=$(/usr/bin/xcode-select -p 2>/dev/null || true)

    local xcode_license_output
    if xcode_license_output=$(xcodebuild -license check 2>&1); then
        echo "Xcode license already accepted."
    elif grep -qi "requires Xcode" <<<"$xcode_license_output"; then
        echo "Full Xcode is not selected; Command Line Tools license was accepted during install."
        return
    else
        echo "Accepting Xcode license..."
        run_sudo /usr/bin/xcodebuild -license accept
    fi

    if [[ "$developer_dir" == /Applications/*.app/Contents/Developer ]] && \
        ! /usr/bin/xcodebuild -checkFirstLaunchStatus >/dev/null 2>&1; then
        echo "Running Xcode first-launch tasks..."
        run_sudo /usr/bin/xcodebuild -runFirstLaunch
    fi
}

trap cleanup_xcode_setup EXIT
request_sudo_for_xcode_setup
if pkgutil --pkg-info com.apple.pkg.CLTools_Executables >/dev/null 2>&1; then
    echo "Xcode Command Line Tools already installed."
else
    install_xcode_cli_tools
fi
accept_xcode_license

# Check if chezmoi is installed
if command -v chezmoi >/dev/null 2>&1; then
    echo "Upgrading chezmoi..."
    # Upgrade chezmoi to the latest version
    chezmoi upgrade
else
    echo "Installing chezmoi..."
    # Install chezmoi if it's not already installed
    curl -fsSL https://git.io/chezmoi | sudo sh -s -- -b /usr/local/bin
fi

# Initialize chezmoi
chezmoi init RyoKamui

# Apply configurations using chezmoi
chezmoi apply
