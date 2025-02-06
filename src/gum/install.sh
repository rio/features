#!/bin/sh
set -e

# grab the version
readonly GUM_VERSION="${VERSION:-latest}"

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

    if [ "${GUM_VERSION}" != "latest" ]; then
        # parse the semantic version for later
        local SEMVER="${GUM_VERSION#[vV]}"      # strip the v
        local SEMVER_MAJOR="${SEMVER%%\.*}"     # split until the first .
        local SEMVER_MINOR="${SEMVER#*.}"       # split starting after the first .
        local SEMVER_MINOR="${SEMVER_MINOR%.*}" # use previous result to grab the first element again
    fi

    local ARCH="$(uname -m)"
    case "${ARCH}" in
        "aarch64") ARCH="arm64" ;;
        "x86_64") ARCH="x86_64" ;;
        *) echo "The current architecture (${ARCH}) is not supported."; exit 1 ;;
    esac

    if [ "${GUM_VERSION}" != "latest" ] ; then
        GUM_CHECKSUMS_URL="https://github.com/charmbracelet/gum/releases/download/v${GUM_VERSION#[vV]}/checksums.txt"
        GUM_URL="https://github.com/charmbracelet/gum/releases/download/v${GUM_VERSION#[vV]}/gum_${GUM_VERSION#[vV]}_Linux_${ARCH}.tar.gz"
    else
        local RELEASES_RESPONSE="$(wget -qO- --tries=3 https://api.github.com/repos/charmbracelet/gum/releases)"
        GUM_CHECKSUMS_URL="$(echo "${RELEASES_RESPONSE}" | grep "browser_download_url.*checksums.txt" | head -n 1 | cut -d '"' -f 4)"
        GUM_URL="$(echo "${RELEASES_RESPONSE}" | grep "browser_download_url.*Linux_${ARCH}" | head -n 1 | cut -d '"' -f 4)"
    fi

    echo "Installing gum ${GUM_VERSION} for ${ARCH} ..."

    echo "Downloading checksums ${GUM_CHECKSUMS_URL} ..."
    wget --no-verbose -O /tmp/checksums.txt "${GUM_CHECKSUMS_URL}"
    local GUM_SHA="$(grep -e Linux_${ARCH}.tar.gz$ /tmp/checksums.txt | cut -d ' ' -f 1)"

    echo "Downloading tarball ${GUM_URL} ..."
    wget --no-verbose -O /tmp/gum.tar.gz "${GUM_URL}"

    echo "Verifying checksum ${GUM_SHA} ..."
    echo "${GUM_SHA} /tmp/gum.tar.gz" | sha256sum -c -

    echo "Extracting..."
    tar xf /tmp/gum.tar.gz --directory=/usr/local/bin --strip-components 1 gum_${GUM_VERSION#[vV]}_Linux_${ARCH}/gum
    chmod +x /usr/local/bin/gum
    rm /tmp/gum.tar.gz

    echo "gum ${GUM_VERSION} for ${ARCH} installed at $(command -v gum)."
}

main "$@"
