#!/bin/sh
set -e

# chezmoi urls and checksums
readonly CHEZMOI_VERSION='2.27.2'
readonly CHEZMOI_SHA_AMD64='4b1e63c073e4b31fd491ae0ddde153a793b67fb99cb1f0cd85d0f43777f6a274'
readonly CHEZMOI_SHA_ARM64='71b4c7b1966f7d4fb51d182fdd769cf5ddcbde4998b0995b504b75cb8bb02537'

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

    echo "Installing chezmoi ${CHEZMOI_VERSION} for ${ARCH} ..."

    case "${ARCH}" in
        "aarch64")
            CHEZMOI_URL="https://github.com/twpayne/chezmoi/releases/download/v${CHEZMOI_VERSION}/chezmoi_${CHEZMOI_VERSION}_linux_arm64.tar.gz"
            CHEZMOI_SHA="${CHEZMOI_SHA_ARM64}"
        ;;
        "x86_64")
            CHEZMOI_URL="https://github.com/twpayne/chezmoi/releases/download/v${CHEZMOI_VERSION}/chezmoi_${CHEZMOI_VERSION}_linux_amd64.tar.gz"
            CHEZMOI_SHA="${CHEZMOI_SHA_AMD64}"
        ;;
        *) echo "The current architecture (${ARCH}) is not supported."; exit 1 ;;
    esac

    echo "Downloading ${CHEZMOI_URL} ..."
    wget -qO /tmp/chezmoi.tar.gz "${CHEZMOI_URL}"

    echo "Verifying checksum ${CHEZMOI_SHA} ..."

    echo "${CHEZMOI_SHA}  /tmp/chezmoi.tar.gz" | sha256sum -c -

    echo "Extracting..."
    tar xf /tmp/chezmoi.tar.gz --directory=/usr/local/bin chezmoi
    rm /tmp/chezmoi.tar.gz

    echo "Chezmoi ${CHEZMOI_VERSION} for ${ARCH} installed at $(command -v chezmoi)."
}

main "$@"
