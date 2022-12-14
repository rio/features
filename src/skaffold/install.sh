#!/bin/sh
set -e

readonly DEFAULT_SKAFFOLD_VERSION='1.39.4'
readonly SKAFFOLD_VERSION=${VERSION:-${DEFAULT_SKAFFOLD_VERSION}}
readonly ARCH="$(uname -m)"

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

    echo "Installing skaffold ${SKAFFOLD_VERSION} for ${ARCH} ..."

    case "${ARCH}" in
        'aarch64')
            SKAFFOLD_URL="https://storage.googleapis.com/skaffold/releases/v${SKAFFOLD_VERSION}/skaffold-linux-arm64"

            case "${SKAFFOLD_VERSION}" in
                "2.0.3")
                    SKAFFOLD_SHA='cbf59fc9150db7888797f140838e17396e680bdddc2b5fe57e5297ceab1a053c' ;;
                "2.0.2")
                    SKAFFOLD_SHA='92f4d22d2f57eaf328dd7a164969b45d774bfd3ba94f8d9ce0e4a79456a02c1c' ;;
                "1.39.4")
                    SKAFFOLD_SHA='605daba875ca856c5d325c49902ea1912165ff641aff1975baecbf93a2e48f1e' ;;
                *) echo "Insupported skaffold version ${SKAFFOLD_VERSION}"; exit 1 ;;
            esac
        ;;

        'x86_64')
            SKAFFOLD_URL="https://storage.googleapis.com/skaffold/releases/v${SKAFFOLD_VERSION}/skaffold-linux-amd64"

            case "${SKAFFOLD_VERSION}" in
                "2.0.3")
                    SKAFFOLD_SHA='7d544461d53d541a6c1e6ba721a8e9f502d6cb240453faf31513f9e4d9b157c1' ;;
                "2.0.2")
                    SKAFFOLD_SHA='32e73cf27d6ba880e8b1dcaff322abcf3f4ed176705ebd6a3562079f0128fc2e' ;;
                "1.39.4")
                    SKAFFOLD_SHA='8e1eacf53600b26e50debeaa86b526e2afd2c87f46a38b3ed64c4bef373d8b1f' ;;
                *) echo "Insupported skaffold version ${SKAFFOLD_VERSION}"; exit 1 ;;
            esac
        ;;

        *) echo "The current architecture (${ARCH}) is not supported."; exit 1 ;;
    esac

    echo "Downloading ${SKAFFOLD_URL} ..."
    wget -qO /usr/local/bin/skaffold "${SKAFFOLD_URL}"

    echo "Verifying checksum ${SKAFFOLD_SHA} ..."
    echo "${SKAFFOLD_SHA}  /usr/local/bin/skaffold" | sha256sum -c -
    chmod +x /usr/local/bin/skaffold

    echo "Skaffold ${SKAFFOLD_VERSION} for ${ARCH} installed at $(command -v skaffold)."
}

main "$@"
