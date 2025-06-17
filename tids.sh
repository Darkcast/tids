#!/usr/bin/env bash

# Description: (tIDs) Touch ID sudo Setup,
# Name: Enable sudo tochid
# This Automatically Configures Touch ID authentication for sudo commands on MacOS only        
# Developed by: Darkcast 
# Version 0.0.1    

# Strict error handling
set -euo pipefail

# Script configuration
SCRIPT_NAME="$(basename "$0")"
SUDO_LOCAL_FILE="/etc/pam.d/sudo_local"
SUDO_LOCAL_TEMPLATE="/etc/pam.d/sudo_local.template"
FORCE=false
LOGGING=false

# Logging function
log() {
    if [[ "$LOGGING" == true ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    else
        echo "$1"
    fi
}

# Error logging function
log_error() {
    if [[ "$LOGGING" == true ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [!] $1" >&2
    else
        echo "[!] $1" >&2
    fi
}

# Info logging function
log_info() {
    if [[ "$LOGGING" == true ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [i] $1"
    else
        echo "[i] $1"
    fi
}

# Success logging function
log_success() {
    if [[ "$LOGGING" == true ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [✓] $1"
    else
        echo "[✓] $1"
    fi
}

# Warning logging function
log_warning() {
    if [[ "$LOGGING" == true ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [!] $1"
    else
        echo "[!] $1"
    fi
}

# Question/prompt logging function
log_prompt() {
    if [[ "$LOGGING" == true ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [?] $1"
    else
        echo "[?] $1"
    fi
}

# Display banner
banner() {
    echo ""
    echo ""
    echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣠⣤⣶⣶⣶⣶⣿⣿⣿⣿⣿⣿⣶⣶⣶⣦⣤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
    echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠿⠿⠿⠿⠿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
    echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣤⣶⣿⣿⣿⣿⣿⠿⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠀⠀⠀⠀⠀⠀⠀⢀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
    echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣤⣿⣿⣿⣿⡿⠛⠉⠀⠀⠀⠀⠀⢀⣠⣤⣴⣦⡀⠀⠀⠀⠀⠀⠀⢀⣤⣦⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠐⣿⣿⣿⣿⣤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
    echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⣿⣿⡿⠋⠀⠀⠀⠀⢀⣤⣶⣿⣿⣿⣿⣿⣿⣿⠟⠀⠀⠀⠀⠀⠀⠹⣿⣿⣿⣿⣿⣿⣿⣶⣤⡀⠀⠀⠀⠀⠙⢿⣿⣿⣿⣶⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
    echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⣿⣿⠛⠀⠀⠀⠀⣤⣾⣿⣿⣿⣿⡿⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠛⣿⣿⣿⣿⣿⣶⣄⠀⠀⠀⠀⠛⣿⣿⣿⣷⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
    echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡀⠀⠀⠀⠀⠀⠀⣀⣾⣿⣿⣿⣿⠛⠁⠀⠀⠀⠀⠀⣀⣤⣦⣶⣶⣶⣾⣿⣶⣶⣶⣦⣤⣀⠀⠀⠀⠀⠀⠈⠛⣿⣿⣿⣿⣶⡀⠀⠀⠀⠙⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
    echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⣿⣿⣿⠀⠀⠀⠀⣠⣿⣿⣿⣿⠛⠀⠀⠀⠀⣀⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⡿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣦⣀⠀⠀⠀⠈⠻⣿⣿⣿⣷⣄⠀⠀⠀⠻⣿⣿⣿⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
    echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⠁⠀⠀⢀⣾⣿⣿⣿⠋⠀⠀⠀⢀⣶⣿⣿⣿⣿⠿⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⢿⣿⣿⣿⣿⣶⡀⠀⠀⠀⠙⣿⣿⣿⣷⠀⠀⠀⠈⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀"
    echo "⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡿⠀⠀⠀⣰⣿⣿⣿⠟⠀⠀⠀⣠⣾⣿⣿⣿⠟⠁⠀⠀⠀⠀⣀⣀⡀⠀⠀⠀⢠⣶⣶⣦⣤⣀⠀⠀⠀⠀⠈⠻⣿⣿⣿⣷⠀⠀⠀⠀⠻⣿⣿⣿⣄⠀⠀⠀⢿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀"
    echo "⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡿⠀⠀⠀⣼⣿⣿⣿⠁⠀⠀⠀⣾⣿⣿⣿⠋⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⠀⠀⠀⠙⣿⣿⣿⣿⣿⣿⣿⣦⡀⠀⠀⠀⠙⠛⠁⠀⠀⠀⠀⠀⠘⣿⣿⣿⣦⠀⠀⠀⢿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀"
    echo "⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⠀⠀⠀⣴⣿⣿⣿⠁⠀⠀⠀⠀⠉⠛⠋⠀⠀⠀⣠⣾⣿⣿⣿⠿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⢿⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⣆⠀⠀⠀⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀"
    echo "⠀⠀⠀⠀⠀⠀⣿⣿⣿⠁⠀⠀⢠⣿⣿⣿⠁⠀⠀⠀⣀⡀⠀⠀⠀⠀⠀⣾⣿⣿⣿⠋⠀⠀⠀⠀⣠⣴⣶⣶⣶⣶⣦⣄⠀⠀⠀⠀⠙⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠿⠿⠁⠀⠀⠀⠘⣿⣿⣿⠀⠀⠀⠀⠀⠀"
    echo "⠀⠀⠀⠀⠀⣼⣿⣿⣿⠀⠀⠀⣿⣿⣿⡟⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⣿⣿⣿⡿⠀⠀⠀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡀⠀⠀⠀⢿⣿⣿⣷⠀⠀⠀⢰⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⠀⠀"
    echo "⠀⠀⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⣿⣿⣿⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⣾⣿⣿⣿⠀⠀⠀⣼⣿⣿⣿⠋⠀⠀⠀⠀⠀⠀⠙⣿⣿⣿⣦⠀⠀⠀⣿⣿⣿⣧⠀⠀⠀⣿⣿⣿⡄⠀⠀⠀⣾⣿⣷⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⠀⠀"
    echo "⠀⠀⠀⠀⠀⣿⣿⣿⠃⠀⠀⠈⣿⣿⡿⠀⠀⠀⣿⣿⣿⣿⠀⠀⠀⣿⣿⣿⠇⠀⠀⢰⣿⣿⣿⠁⠀⠀⢠⣶⣶⡀⠀⠀⠈⣿⣿⣿⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⣿⣿⣿⣧⠀⠀⠀⣿⣿⣿⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⠀⠀"
    echo "⠀⠀⠀⠀⠀⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⠀⠀⠀⣿⣿⣿⡀⠀⠀⠸⣿⣿⣿⠀⠀⠀⣿⣿⣿⣿⠀⠀⠀⣿⣿⣿⡆⠀⠀⢸⣿⣿⣿⠀⠀⠀⣿⣿⣿⣿⠀⠀⠀⣿⣿⣿⡆⠀⠀⢸⣿⣿⣿⠀⠀⠀⠀⠀"
    echo "⠀⠀⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⣀⣤⡀⠀⠀⠀⣿⣿⣿⣿⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⠀⠀⠀⣿⣿⣿⡇⠀⠀⢸⣿⣿⣿⠀⠀⠀⣿⣿⣿⣿⠀⠀⠀⣿⣿⣿⡇⠀⠀⢸⣿⣿⣿⠀⠀⠀⠀⠀"
    echo "⠀⠀⠀⠀⠀⢻⣿⣿⣿⠀⠀⢸⣿⣿⣿⠀⠀⠀⣿⣿⣿⣿⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⠀⠀⠀⣿⣿⣿⡇⠀⠀⢸⣿⣿⣿⠀⠀⠀⣿⣿⣿⣿⠀⠀⠀⣿⣿⣿⡇⠀⠀⣿⣿⣿⡏⠀⠀⠀⠀⠀"
    echo "⠀⠀⠀⠀⠀⠈⣿⣿⣿⠀⠀⢸⣿⣿⣿⠀⠀⠀⣿⣿⣿⡟⠀⠀⠀⣿⣿⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡿⠀⠀⠀⠈⠛⠋⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⣿⣿⣿⡿⠀⠀⠀⣿⣿⣿⠃⠀⢠⣿⣿⣿⠀⠀⠀⠀⠀⠀"
    echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⣿⣿⣿⠀⠀⠀⢠⣾⣷⣄⠀⠀⠀⣿⣿⣿⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⣿⣿⣿⡏⠀⠀⠀⣿⣿⣿⠀⠀⠀⠛⠛⠉⠀⠀⠀⠀⠀⠀"
    echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡏⠀⠀⠀⣿⣿⣿⠀⠀⠀⠈⣿⣿⡿⠀⠀⠀⣾⣿⣿⡿⠀⠀⠀⣿⣿⣿⠃⠀⠀⢠⣿⣿⣷⠀⠀⠀⣸⣿⣿⣿⠀⠀⠀⣿⣿⣿⡇⠀⠀⢠⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
    echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣿⣿⣿⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡇⠀⠀⢀⣿⣿⣿⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⣿⣿⣿⡏⠀⠀⠀⣿⣿⣿⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
    echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⠋⠀⠀⠀⣿⣿⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⠀⠀⠀⣸⣿⣿⣿⠀⠀⠀⣿⣿⣿⡏⠀⠀⠀⣿⣿⣿⠁⠀⠀⢸⣿⣿⣿⠀⠀⠀⣼⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
    echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡟⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⡿⠀⠀⠀⣿⣿⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
    echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⠋⠀⠀⠀⣼⣿⣿⣷⠀⠀⠀⢰⣿⣿⣿⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⣾⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⠃⠀⠀⢠⣿⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
    echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠀⠀⠀⣠⣿⣿⣿⡿⠀⠀⠀⢠⣿⣿⣿⠃⠀⠀⢀⣿⣿⣿⠃⠀⠀⢀⣿⣿⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⠟⠀⠀⠀⡾⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
    echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⠋⠀⠀⠀⣴⣿⣿⣿⠋⠀⠀⠀⣿⣿⣿⡟⠀⠀⠀⣿⣿⣿⡟⠀⠀⠀⣾⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
    echo ""
    echo ""
    echo "--------------------------------------------------------------------------------"
    echo " [i] Touch ID sudo Setup (tIDs)                                                 "
    echo " [i] Code Name: Aurora                                                          "
    echo " [i] Version: 0.0.1                                                             "
    echo " [i] By Darkcast                                                                "
    echo "--------------------------------------------------------------------------------"
    echo ""
}

# Usage function
usage() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Configure Touch ID authentication for sudo commands on macOS.

OPTIONS:
    -f, --force     Force reconfiguration even if sudo_local already exists
    -l, --logging   Enable detailed logging with timestamps
    -h, --help      Show this help message

EXAMPLES:
    $SCRIPT_NAME                 # Configure Touch ID (fails if already configured)
    $SCRIPT_NAME --force         # Force reconfiguration
    $SCRIPT_NAME --logging       # Enable detailed logging
    $SCRIPT_NAME -f -l           # Force reconfiguration with logging
    $SCRIPT_NAME --help          # Show this help

EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f|--force)
                FORCE=true
                shift
                ;;
            -l|--logging)
                LOGGING=true
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
}

# Check if running on macOS
check_macos() {
    if [[ "$(uname)" != "Darwin" ]]; then
        echo "This script is designed for macOS only."
        echo "Playing sad trumbone"
        xdg-open "https://www.youtube.com/watch?v=CQeezCdF4mk&ab_channel=GamingSoundFX"
        log_error "This script is designed for macOS only."
        exit 1
    fi
}

# Check if template file exists
check_template() {
    if [[ ! -f "$SUDO_LOCAL_TEMPLATE" ]]; then
        log_error "Template file '$SUDO_LOCAL_TEMPLATE' not found."
        log_error "This template should exist on macOS systems with Touch ID support."
        exit 1
    fi
    if [[ "$LOGGING" == true ]]; then
        log_info "Template file found: $SUDO_LOCAL_TEMPLATE"
    fi
}

# Create backup if file exists
create_backup() {
    if [[ -f "$SUDO_LOCAL_FILE" ]]; then
        local backup_file="${SUDO_LOCAL_FILE}.backup.$(date +%s)"
        if sudo cp "$SUDO_LOCAL_FILE" "$backup_file"; then
            if [[ "$LOGGING" == true ]]; then
                log_info "Backup created: $backup_file"
            fi
        else
            log_error "Failed to create backup. Aborting."
            exit 1
        fi
    fi
}

# Copy template to target location
copy_template() {
    if [[ "$LOGGING" == true ]]; then
        log_info "Creating '$SUDO_LOCAL_FILE' from template..."
    fi
    if sudo cp "$SUDO_LOCAL_TEMPLATE" "$SUDO_LOCAL_FILE"; then
        if [[ "$LOGGING" == true ]]; then
            log_success "Template copied successfully."
        fi
    else
        log_error "Failed to copy template to '$SUDO_LOCAL_FILE'."
        log_error "Please ensure you have administrator privileges."
        exit 1
    fi
}

# Uncomment the pam_tid.so line
enable_touch_id() {
    if [[ "$LOGGING" == true ]]; then
        log_info "Enabling Touch ID authentication..."
    fi
    
    # Check if the commented line exists in the file
    if ! sudo grep -q "^#auth[[:space:]]*sufficient[[:space:]]*pam_tid\.so" "$SUDO_LOCAL_FILE"; then
        log_error "Expected commented pam_tid.so line not found in '$SUDO_LOCAL_FILE'."
        log_error "The template file may have an unexpected format."
        exit 1
    fi
    
    # Uncomment the pam_tid.so line using sed
    if sudo sed -i '' 's/^#\(auth[[:space:]]*sufficient[[:space:]]*pam_tid\.so\)/\1/' "$SUDO_LOCAL_FILE"; then
        if [[ "$LOGGING" == true ]]; then
            log_success "Touch ID line uncommented successfully."
        fi
    else
        log_error "Failed to uncomment pam_tid.so line."
        exit 1
    fi
}

# Verify the configuration was applied correctly
verify_configuration() {
    if [[ "$LOGGING" == true ]]; then
        log_info "Verifying configuration..."
    fi
    
    if sudo grep -q "^auth[[:space:]]*sufficient[[:space:]]*pam_tid\.so" "$SUDO_LOCAL_FILE"; then
        log_success "Touch ID configuration verified successfully!"
        return 0
    else
        log_error "Configuration verification failed."
        log_error "The pam_tid.so line may not have been uncommented correctly."
        return 1
    fi
}

# Main function
main() {
    banner
    parse_args "$@"
    
    if [[ "$LOGGING" == true ]]; then
        log_info "Starting Touch ID configuration for sudo..."
    fi
    
    # Perform system checks
    check_macos
    check_template
    
    # Check if sudo_local file already exists
    if [[ -f "$SUDO_LOCAL_FILE" ]] && [[ "$FORCE" == false ]]; then
        log_info "The file '$SUDO_LOCAL_FILE' already exists."
        echo
        log_prompt "If you want to reconfigure, you have two options:"
        echo "   1. Run with --force flag: $SCRIPT_NAME --force"
        echo "   2. Remove the existing file: sudo rm '$SUDO_LOCAL_FILE'"
        echo
        exit 0
    fi
    
    # Create backup if file exists and we're forcing
    if [[ "$FORCE" == true ]]; then
        create_backup
    fi
    
    # Perform the configuration
    copy_template
    enable_touch_id
    
    # Verify everything worked
    if verify_configuration; then
        echo
        echo "[*] Touch ID configuration completed successfully!"
        echo
        log_info "You can now test it by running a sudo command, for example:"
        echo "   sudo ls"
        echo
        log_info "Touch ID should prompt you for authentication instead of asking for your password."
    else
        log_error "Configuration completed but verification failed."
        log_error "You may need to check '$SUDO_LOCAL_FILE' manually."
        exit 1
    fi
}

# Run main function with all arguments
main "$@"