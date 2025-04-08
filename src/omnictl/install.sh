#!/bin/sh
set -e

# grab the version
readonly OMNICTL_VERSION="${VERSION:-latest}"

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

    local OMNICTL_URL="https://github.com/siderolabs/omni/releases/latest/download/omnictl-linux-${ARCH}"
    if [ "${OMNICTL_VERSION}" != "latest" ] ; then
        OMNICTL_URL="https://github.com/siderolabs/omni/releases/download/v${OMNICTL_VERSION#[vV]}/omnictl-linux-${ARCH}"
    fi

    echo "Installing omnictl ${OMNICTL_VERSION} for ${ARCH} ..."

    echo "Downloading ${OMNICTL_URL} ..."
    wget --no-verbose -O /usr/local/bin/omnictl "${OMNICTL_URL}"
    chmod +x /usr/local/bin/omnictl

    echo "Add autocompletion for bash"
    mkdir -p /etc/bash_completion.d/
    omnictl completion bash > /etc/bash_completion.d/omnictl

    echo "omnictl ${OMNICTL_VERSION} for ${ARCH} installed at $(command -v omnictl) with checksum $(sha256sum $(command -v omnictl))."
}

main "$@"
