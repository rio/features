#!/bin/sh
set -e

# urls and checksums
readonly KUSTOMIZE_VERSION='4.5.7'
readonly KUSTOMIZE_SHA_ARM64='65665b39297cc73c13918f05bbe8450d17556f0acd16242a339271e14861df67'
readonly KUSTOMIZE_SHA_AMD64='701e3c4bfa14e4c520d481fdf7131f902531bfc002cb5062dcf31263a09c70c9'

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

    echo "Installing kustomize ${KUSTOMIZE_VERSION} for ${ARCH} ..."

    case "${ARCH}" in
        "aarch64")
            KUSTOMIZE_URL="https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_arm64.tar.gz"
            KUSTOMIZE_SHA="${KUSTOMIZE_SHA_ARM64}"
        ;;
        "x86_64")
            KUSTOMIZE_URL="https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_amd64.tar.gz"
            KUSTOMIZE_SHA="${KUSTOMIZE_SHA_AMD64}"
        ;;
        *) echo "The current architecture (${ARCH}) is not supported."; exit 1 ;;
    esac

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
