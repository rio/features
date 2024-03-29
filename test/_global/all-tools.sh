#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "skaffold" skaffold version
check "chezmoi" chezmoi --version
check "kustomize" kustomize version
check "k9s" k9s version
check "k3d" k3d version
check "vcluster" vcluster version

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
