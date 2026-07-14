#!/bin/bash
# Install WezTerm (nightly) via the official APT repo

# Load helpers
script_dir="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=./helpers.sh
source "$script_dir/helpers.sh"
set_strict_mode

log_header "Installing WezTerm (nightly)"

# WezTerm is a rolling release, so track the nightly package instead of pinning
# to infrequent stable tags.
KEYRING="/usr/share/keyrings/wezterm-fury.gpg"
REPO_LIST="/etc/apt/sources.list.d/wezterm.list"

add_wezterm_repo() {
    if [[ -f "$REPO_LIST" ]]; then
        log_info "WezTerm APT repo already configured"
        return 0
    fi

    log_info "Adding WezTerm APT repo..."
    if ! curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o "$KEYRING"; then
        die "Failed to fetch/dearmor WezTerm GPG key"
    fi

    if ! echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee "$REPO_LIST" >/dev/null; then
        die "Failed to write WezTerm APT source list"
    fi

    sudo chmod 644 "$KEYRING"
}

add_wezterm_repo
apt_update
install_package "wezterm-nightly" "wezterm"

verify_installation wezterm "WezTerm" "--version"
