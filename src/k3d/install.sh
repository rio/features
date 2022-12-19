#!/bin/sh
set -e

# grab the version
readonly K3D_VERSION="${VERSION:-latest}"

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

    local K3D_URL="https://github.com/k3d-io/k3d/releases/latest/download/k3d-linux-${ARCH}"
    if [ "${K3D_VERSION}" != "latest" ] ; then
        K3D_URL="https://github.com/k3d-io/k3d/releases/download/v${K3D_VERSION#[vV]}/k3d-linux-${ARCH}"
    fi

    echo "Installing k3d ${K3D_VERSION} for ${ARCH} ..."

    echo "Downloading ${K3D_URL} ..."
    wget --no-verbose -O /usr/local/bin/k3d "${K3D_URL}"
    chmod +x /usr/local/bin/k3d

    echo "k3d ${K3D_VERSION} for ${ARCH} installed at $(command -v k3d) with checksum $(sha256sum $(command -v k3d))."
}

main "$@"
