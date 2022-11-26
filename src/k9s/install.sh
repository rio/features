#!/bin/sh
set -e

# urls and checksums
readonly K9S_VERSION='0.26.7'
readonly K9S_SHA_ARM64='2888feae5298517cf4862251a8877ff978b3eb234cbc3ebc0d9eb07fc671673d'
readonly K9S_SHA_AMD64='f774bb75045e361e17a4f267491c5ec66f41db7bffd996859ffb1465420af249'

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

    echo "Installing k9s ${K9S_VERSION} for ${ARCH} ..."

    case "${ARCH}" in
        "aarch64")
            K9S_URL="https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_arm64.tar.gz"
            K9S_SHA="${K9S_SHA_ARM64}"
        ;;
        "x86_64")
            K9S_URL="https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_x86_64.tar.gz"
            K9S_SHA="${K9S_SHA_AMD64}"
        ;;
        *) echo "The current architecture (${ARCH}) is not supported."; exit 1 ;;
    esac

    echo "Downloading ${K9S_URL} ..."
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
