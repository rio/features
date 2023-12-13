#!/bin/sh
set -e

# grab the version
readonly VCLUSTER_VERSION="${VERSION:-latest}"

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

    if [ "${VCLUSTER_VERSION}" != "latest" ] ; then
        VCLUSTER_CHECKSUM_URL="https://github.com/loft-sh/vcluster/releases/download/v${VCLUSTER_VERSION#[vV]}/checksums.txt"
        VCLUSTER_URL="https://github.com/loft-sh/vcluster/releases/download/v${VCLUSTER_VERSION#[vV]}/vcluster-linux-${ARCH}"
    else
        local RELEASES_RESPONSE="$(wget -qO- --tries=3 https://api.github.com/repos/loft-sh/vcluster/releases)"
        VCLUSTER_CHECKSUM_URL="$(echo "${RELEASES_RESPONSE}" | grep "browser_download_url.*checksums.txt" | head -n 1 | cut -d '"' -f 4)"
        VCLUSTER_URL="$(echo "${RELEASES_RESPONSE}" | grep "browser_download_url.*vcluster-linux-${ARCH}" | head -n 1 | cut -d '"' -f 4)"
    fi

    echo "Installing vcluster ${VCLUSTER_VERSION} for ${ARCH} ..."

    echo "Downloading checksums ${VCLUSTER_CHECKSUM_URL} ..."
    wget --no-verbose -O /tmp/checksums.txt "${VCLUSTER_CHECKSUM_URL}"

    echo "Downloading ${VCLUSTER_URL} ..."
    wget --no-verbose -O /tmp/vcluster "${VCLUSTER_URL}"
    local VCLUSTER_SHA="$(grep -e vcluster-linux-${ARCH}$ /tmp/checksums.txt | cut -d ' ' -f 1)"

    echo "Verifying checksum ${VCLUSTER_SHA} ..."
    echo "${VCLUSTER_SHA}  /tmp/vcluster" | sha256sum -c -

    echo "Installing..."
    mv /tmp/vcluster /usr/local/bin/vcluster
    chmod +x /usr/local/bin/vcluster
    rm /tmp/checksums.txt

    echo "vcluster ${VCLUSTER_VERSION} for ${ARCH} installed at $(command -v vcluster)."
}

main "$@"
