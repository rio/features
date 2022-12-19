#!/bin/sh
set -e

# grab the version
readonly CHEZMOI_VERSION="${VERSION:-latest}"

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

    echo "Installing chezmoi ${CHEZMOI_VERSION} for ${ARCH} ..."

    local CHEZMOI_CHECKSUMS_URL="https://github.com/twpayne/chezmoi/releases/latest/download/"
    local CHEZMOI_URL="https://github.com/twpayne/chezmoi/releases/latest/download/checksums.txt"

    if [ "${CHEZMOI_VERSION}" != "latest" ] ; then
        CHEZMOI_CHECKSUMS_URL="https://github.com/twpayne/chezmoi/releases/download/v${CHEZMOI_VERSION#[vV]}/checksums.txt"
        CHEZMOI_URL="https://github.com/twpayne/chezmoi/releases/download/v${CHEZMOI_VERSION#[vV]}/chezmoi_${CHEZMOI_VERSION#[vV]}_linux_${ARCH}.tar.gz"
    else
        local RELEASES_RESPONSE="$(wget -qO- https://api.github.com/repos/twpayne/chezmoi/releases)"
        CHEZMOI_CHECKSUMS_URL="$(echo "${RELEASES_RESPONSE}" | grep "browser_download_url.*checksums.txt" | head -n 1 | cut -d '"' -f 4)"
        CHEZMOI_URL="$(echo "${RELEASES_RESPONSE}" | grep "browser_download_url.*linux_${ARCH}.tar.gz" | head -n 1 | cut -d '"' -f 4)"
    fi

    echo "Downloading checksums ${CHEZMOI_CHECKSUMS_URL} ..."
    wget --no-verbose -O /tmp/checksums.txt "${CHEZMOI_CHECKSUMS_URL}"
    local CHEZMOI_SHA="$(grep linux_${ARCH}.tar.gz /tmp/checksums.txt | cut -d ' ' -f 1)"

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
