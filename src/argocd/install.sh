#!/bin/sh
set -e

# grab the version
readonly ARGOCD_VERSION="${VERSION:-latest}"

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

    local ARGOCD_URL="https://github.com/argoproj/argo-cd/releases/download/argocd-linux-${ARCH}"
    if [ "${ARGOCD_VERSION}" != "latest" ] ; then
        ARGOCD_URL="https://github.com/argoproj/argo-cd/releases/download/v${ARGOCD_VERSION#[vV]}/argocd-linux-${ARCH}"
    fi

    echo "Installing argocd ${ARGOCD_VERSION} for ${ARCH} ..."

    echo "Downloading ${ARGOCD_URL} ..."
    wget --no-verbose -O /usr/local/bin/argocd "${ARGOCD_URL}"
    chmod +x /usr/local/bin/argocd

    echo "argocd ${ARGOCD_VERSION} for ${ARCH} installed at $(command -v argocd) with checksum $(sha256sum $(command -v argocd))."
}

main "$@"
