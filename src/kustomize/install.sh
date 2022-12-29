#!/bin/sh
set -e

# grab the version
readonly KUSTOMIZE_VERSION="${VERSION:-latest}"

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

    if [ "${KUSTOMIZE_VERSION}" != "latest" ] ; then
        KUSTOMIZE_CHECKSUMS_URL="https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION#[vV]}/checksums.txt"
        KUSTOMIZE_URL="https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION#[vV]}/kustomize_v${KUSTOMIZE_VERSION#[vV]}_linux_${ARCH}.tar.gz"
    else
        local RELEASES_RESPONSE="$(wget -qO- --tries=3 https://api.github.com/repos/kubernetes-sigs/kustomize/releases)"
        KUSTOMIZE_CHECKSUMS_URL="$(echo "${RELEASES_RESPONSE}" | grep "browser_download_url.*checksums.txt" | head -n 1 | cut -d '"' -f 4)"
        KUSTOMIZE_URL="$(echo "${RELEASES_RESPONSE}" | grep "browser_download_url.*linux_${ARCH}" | head -n 1 | cut -d '"' -f 4)"
    fi

    echo "Installing kustomize ${KUSTOMIZE_VERSION} for ${ARCH} ..."

    echo "Downloading checksums ${KUSTOMIZE_CHECKSUMS_URL} ..."
    wget --no-verbose -O /tmp/checksums.txt "${KUSTOMIZE_CHECKSUMS_URL}"
    local KUSTOMIZE_SHA="$(grep linux_${ARCH} /tmp/checksums.txt | cut -d ' ' -f 1)"

    echo "Downloading ${KUSTOMIZE_URL} ..."
    wget --no-verbose -O /tmp/kustomize.tar.gz "${KUSTOMIZE_URL}"

    echo "Verifying checksum ${KUSTOMIZE_SHA} ..."
    echo "${KUSTOMIZE_SHA}  /tmp/kustomize.tar.gz" | sha256sum -c -

    echo "Extracting..."
    tar xf /tmp/kustomize.tar.gz --directory=/usr/local/bin kustomize
    chmod +x /usr/local/bin/kustomize
    rm /tmp/kustomize.tar.gz

    echo "Kustomize ${KUSTOMIZE_VERSION} for ${ARCH} installed at $(command -v kustomize)."
}

main "$@"
