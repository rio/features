#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "chezmoi specific version 2.27.3" /bin/bash -c "chezmoi --version | grep 'v2.27.3'"

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults