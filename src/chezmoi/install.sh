#!/bin/sh
set -e

# chezmoi urls and checksums
readonly CHEZMOI_VERSION='2.27.2'
readonly CHEZMOI_SHA_AMD64='4b1e63c073e4b31fd491ae0ddde153a793b67fb99cb1f0cd85d0f43777f6a274'
readonly CHEZMOI_SHA_ARM64='71b4c7b1966f7d4fb51d182fdd769cf5ddcbde4998b0995b504b75cb8bb02537'

# required tools
readonly DOWNLOAD_CLI="$(command -v curl || command -v wget)"
readonly TAR_CLI="$(command -v tar)"
readonly SHA256SUM_CLI="$(command -v sha256sum)"


preflight () {
    local FAILED=false

    if [ -z "${DOWNLOAD_CLI}" ]; then
        echo "curl or wget is required for this feature to work."
        FAILED=true
    fi

    if [ -z "${TAR_CLI}" ]; then
        echo "tar is required for this feature to work."
        FAILED=true
    fi

    if [ -z "${SHA256SUM_CLI}" ]; then
        echo "sha256sum is required for this feature to work."
        FAILED=true
    fi

    if ${FAILED}; then
        exit 1
    fi
}

main () {
    preflight

    local ARCH="$(uname -m)"

    echo "Installing chezmoi ${CHEZMOI_VERSION} for ${ARCH} ..."

    case "${ARCH}" in
        "aarch64")
            CHEZMOI_URL="https://github.com/twpayne/chezmoi/releases/download/v${CHEZMOI_VERSION}/chezmoi_${CHEZMOI_VERSION}_linux_arm64.tar.gz"
            CHEZMOI_SHA="${CHEZMOI_SHA_ARM64}"
        ;;
        "x86_64")
            CHEZMOI_URL="https://github.com/twpayne/chezmoi/releases/download/v${CHEZMOI_VERSION}/chezmoi_${CHEZMOI_VERSION}_linux_amd64.tar.gz"
            CHEZMOI_SHA="${CHEZMOI_SHA_AMD64}"
        ;;
        *) echo "The current architecture (${ARCH}) is not supported."; exit 1 ;;
    esac

    echo "Downloading ${CHEZMOI_URL} using ${DOWNLOAD_CLI} ..."

    case "$(basename ${DOWNLOAD_CLI})" in
        "curl")
            curl -sSfLo /tmp/chezmoi.tar.gz "${CHEZMOI_URL}"
        ;;
        "wget")
            wget -qO /tmp/chezmoi.tar.gz "${CHEZMOI_URL}"
        ;;
        *) echo "Unsupported download cli $(basename ${DOWNLOAD_CLI})."; exit 1;
    esac

    echo "Verifying checksum ${CHEZMOI_SHA} ..."

    echo "${CHEZMOI_SHA}  /tmp/chezmoi.tar.gz" | ${SHA256SUM_CLI} -c -

    echo "Extracting..."
    tar xf /tmp/chezmoi.tar.gz --directory=/usr/local/bin chezmoi
    rm /tmp/chezmoi.tar.gz

    echo "Chezmoi ${CHEZMOI_VERSION} for ${ARCH} installed at $(command -v chezmoi)."
}

main "$@"
