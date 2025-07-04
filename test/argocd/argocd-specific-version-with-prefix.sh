#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "argocd specific version v3.0.6" /bin/bash -c "argocd version | grep 'v3.0.6'"

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults