#!/bin/sh
set -e

# grab the version
readonly K9S_VERSION="${VERSION:-latest}"

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
        "x86_64")
            # parse the semantic version to determine what arch to use
            # the file naming changed from 0.27.0 onward: https://github.com/derailed/k9s/pull/1910
            local SEMVER="${K9S_VERSION#[vV]}"      # strip the v
            local SEMVER_MAJOR="${SEMVER%%\.*}"     # split until the first .
            local SEMVER_MINOR="${SEMVER#*.}"       # split starting after the first .
            local SEMVER_MINOR="${SEMVER_MINOR%.*}" # use previous result to grab the first element again

            ARCH="amd64"

            if [ "${SEMVER_MAJOR}" -eq "0" ] && [ "${SEMVER_MINOR}" -lt "27" ]; then
                ARCH="x86_64"
            fi
        ;;
        *) echo "The current architecture (${ARCH}) is not supported."; exit 1 ;;
    esac

    local K9S_CHECKSUMS_URL="https://github.com/derailed/k9s/releases/latest/download/checksums.txt"
    local K9S_URL="https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_${ARCH}.tar.gz"

    if [ "${K9S_VERSION}" != "latest" ] ; then
        K9S_CHECKSUMS_URL="https://github.com/derailed/k9s/releases/download/v${K9S_VERSION#[vV]}/checksums.txt"
        K9S_URL="https://github.com/derailed/k9s/releases/download/v${K9S_VERSION#[vV]}/k9s_Linux_${ARCH}.tar.gz"
    fi

    echo "Installing k9s ${K9S_VERSION} for ${ARCH} ..."

    echo "Downloading checksums ${K9S_CHECKSUMS_URL} ..."
    wget --no-verbose -O /tmp/checksums.txt "${K9S_CHECKSUMS_URL}"
    local K9S_SHA="$(grep Linux_${ARCH} /tmp/checksums.txt | cut -d ' ' -f 1)"

    echo "Downloading tarball ${K9S_URL} ..."
    wget --no-verbose -O /tmp/k9s.tar.gz "${K9S_URL}"

    echo "Verifying checksum ${K9S_SHA} ..."
    echo "${K9S_SHA}  /tmp/k9s.tar.gz" | sha256sum -c -

    echo "Extracting..."
    tar xf /tmp/k9s.tar.gz --directory=/usr/local/bin k9s
    chmod +x /usr/local/bin/k9s
    rm /tmp/k9s.tar.gz

    echo "k9s ${K9S_VERSION} for ${ARCH} installed at $(command -v k9s)."
}

main "$@"
