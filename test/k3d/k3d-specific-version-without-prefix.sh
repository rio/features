#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "k3d specific version 5.4.4" /bin/bash -c "k3d version | grep 'v5.4.4'"

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults