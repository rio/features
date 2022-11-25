#!/bin/sh
set -e

# urls and checksums
readonly SKAFFOLD_VERSION='1.39.4'
readonly SKAFFOLD_SHA_ARM64='605daba875ca856c5d325c49902ea1912165ff641aff1975baecbf93a2e48f1e'
readonly SKAFFOLD_SHA_AMD64='8e1eacf53600b26e50debeaa86b526e2afd2c87f46a38b3ed64c4bef373d8b1f'

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

    echo "Installing skaffold ${SKAFFOLD_VERSION} for ${ARCH} ..."

    case "${ARCH}" in
        "aarch64")
            SKAFFOLD_URL="https://storage.googleapis.com/skaffold/releases/v${SKAFFOLD_VERSION}/skaffold-linux-arm64"
            SKAFFOLD_SHA="${SKAFFOLD_SHA_ARM64}"
        ;;
        "amd64")
            SKAFFOLD_URL="https://storage.googleapis.com/skaffold/releases/v${SKAFFOLD_VERSION}/skaffold-linux-amd64"
            SKAFFOLD_SHA="${SKAFFOLD_SHA_AMD64}"
        ;;
        *) echo "The current architecture (${ARCH}) is not supported."; exit 1 ;;
    esac

    echo "Downloading ${SKAFFOLD_URL} using ${DOWNLOAD_CLI} ..."

    case "$(basename ${DOWNLOAD_CLI})" in
        "curl")
            curl -sSfLo /usr/local/bin/skaffold "${SKAFFOLD_URL}"
        ;;
        "wget")
            wget -qO /usr/local/bin/skaffold "${SKAFFOLD_URL}"
        ;;
        *) echo "Unsupported download cli $(basename ${DOWNLOAD_CLI})."; exit 1;
    esac

    echo "Verifying checksum ${SKAFFOLD_SHA} ..."
    echo "${SKAFFOLD_SHA}  /usr/local/bin/skaffold" | ${SHA256SUM_CLI} -c - 
    chmod +x /usr/local/bin/skaffold
}
    echo "Skaffold ${SKAFFOLD_VERSION} for ${ARCH} installed at $(command -v skaffold)."
}

main "$@"
