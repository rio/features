#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "vcluster specific version 0.12.3" /bin/bash -c "vcluster version | grep '0.12.3'"

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults