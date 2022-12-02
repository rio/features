#!/bin/sh
set -e

# urls and checksums
readonly K3D_VERSION='5.4.6'
readonly K3D_SHA_ARM64='36db97dfb3f5b56c7cd048924d87abfa5f499c62f524e00e2500fe75f88056ae'
readonly K3D_SHA_AMD64='8075d40c74c97d2642f15f535cb48d6d6e82df143f528833a193d87caac6a176'

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

    echo "Installing k3d ${K3D_VERSION} for ${ARCH} ..."

    case "${ARCH}" in
        "aarch64")
            K3D_URL="https://github.com/k3d-io/k3d/releases/download/v${K3D_VERSION}/k3d-linux-arm64"
            K3D_SHA="${K3D_SHA_ARM64}"
        ;;
        "x86_64")
            K3D_URL="https://github.com/k3d-io/k3d/releases/download/v${K3D_VERSION}/k3d-linux-amd64"
            K3D_SHA="${K3D_SHA_AMD64}"
        ;;
        *) echo "The current architecture (${ARCH}) is not supported."; exit 1 ;;
    esac

    echo "Downloading ${K3D_URL} ..."
    wget --no-verbose -O /usr/local/bin/k3d "${K3D_URL}"

    echo "Verifying checksum ${K3D_SHA} ..."
    echo "${K3D_SHA}  /usr/local/bin/k3d" | sha256sum -c -
    chmod +x /usr/local/bin/k3d

    echo "k3d ${K3D_VERSION} for ${ARCH} installed at $(command -v k3d)."
}

main "$@"
