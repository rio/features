#!/bin/sh
set -e

# grab the version
readonly TALOSCTL_VERSION="${VERSION:-latest}"

# apt-get configuration
export DEBIAN_FRONTEND=noninteractive


preflight () {
    if command -v wget > /dev/null; then
        return
    fi

    if [ -e /etc/os-release ]; then
        . /etc/os-release
    fi

    case "${ID}" in
        'debian' | 'ubuntu')
            apt-get update
            apt-get install -y --no-install-recommends \
                wget \
                ca-certificates
        ;;
        'fedora')
            dnf -y install wget
        ;;
        *) echo "The ${ID} distribution is not supported."; exit 1 ;;
    esac
}

main () {
    preflight

    local ARCH="$(uname -m)"
    case "${ARCH}" in
        "aarch64") ARCH="arm64" ;;
        "x86_64") ARCH="amd64" ;;
        *) echo "The current architecture (${ARCH}) is not supported."; exit 1 ;;
    esac

    local TALOSCTL_URL="https://github.com/siderolabs/talos/releases/latest/download/talosctl-linux-${ARCH}"
    if [ "${TALOSCTL_VERSION}" != "latest" ] ; then
        TALOSCTL_URL="https://github.com/siderolabs/talos/releases/download/v${TALOSCTL_VERSION#[vV]}/talosctl-linux-${ARCH}"
    fi

    echo "Installing talosctl ${TALOSCTL_VERSION} for ${ARCH} ..."

    echo "Downloading ${TALOSCTL_URL} ..."
    wget --no-verbose -O /usr/local/bin/talosctl "${TALOSCTL_URL}"
    chmod +x /usr/local/bin/talosctl

    echo "Add autocompletion for bash"
    mkdir -p /etc/bash_completion.d/
    talosctl completion bash > /etc/bash_completion.d/talosctl

    echo "talosctl ${TALOSCTL_VERSION} for ${ARCH} installed at $(command -v talosctl) with checksum $(sha256sum $(command -v talosctl))."
}

main "$@"
