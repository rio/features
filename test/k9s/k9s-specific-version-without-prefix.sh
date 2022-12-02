#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "k9s specific version 0.26.5" /bin/bash -c "k9s version --short | grep 'v0.26.5'"

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults