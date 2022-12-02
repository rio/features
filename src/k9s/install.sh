#!/bin/sh
set -e

# version
readonly K9S_VERSION='0.26.7'

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
        "x86_64") ARCH="x86_64" ;;
        *) echo "The current architecture (${ARCH}) is not supported."; exit 1 ;;
    esac

    echo "Installing k9s ${K9S_VERSION} for ${ARCH} ..."

    local K9S_CHECKSUMS_URL="https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/checksums.txt"
    local K9S_URL="https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_${ARCH}.tar.gz"

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
