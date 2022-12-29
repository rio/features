#!/bin/sh
set -e


# grap the version
readonly SKAFFOLD_VERSION="${VERSION:-latest}"

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

    local SKAFFOLD_CHECKSUMS_URL="https://github.com/GoogleContainerTools/skaffold/releases/latest/download/skaffold-linux-${ARCH}.sha256"
    local SKAFFOLD_URL="https://github.com/GoogleContainerTools/skaffold/releases/latest/download/skaffold-linux-${ARCH}"

    if [ "${SKAFFOLD_VERSION}" != "latest" ] ; then
        SKAFFOLD_CHECKSUMS_URL="https://github.com/GoogleContainerTools/skaffold/releases/download/v${SKAFFOLD_VERSION#[vV]}/skaffold-linux-${ARCH}.sha256"
        SKAFFOLD_URL="https://github.com/GoogleContainerTools/skaffold/releases/download/v${SKAFFOLD_VERSION#[vV]}/skaffold-linux-${ARCH}"
    fi

    echo "Installing skaffold ${SKAFFOLD_VERSION} for ${ARCH} ..."

    echo "Downloading checksums ${SKAFFOLD_CHECKSUMS_URL} ..."
    wget --no-verbose -O /tmp/checksums.txt "${SKAFFOLD_CHECKSUMS_URL}"
    local SKAFFOLD_SHA="$(grep ${ARCH} /tmp/checksums.txt | cut -d ' ' -f 1)"

    echo "Downloading ${SKAFFOLD_URL} ..."
    wget -qO /usr/local/bin/skaffold "${SKAFFOLD_URL}"

    echo "Verifying checksum ${SKAFFOLD_SHA} ..."
    echo "${SKAFFOLD_SHA}  /usr/local/bin/skaffold" | sha256sum -c -
    chmod +x /usr/local/bin/skaffold

    echo "Skaffold ${SKAFFOLD_VERSION} for ${ARCH} installed at $(command -v skaffold)."
}

main "$@"
