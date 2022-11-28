#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "skaffold is installed" skaffold version --output="skaffold version {{.Version}}, config version {{.ConfigVersion}}, commit {{.GitCommit}}, built at {{.BuildDate}} using {{.GoVersion}}"

# check version output
check "skaffold version matches requested version" /bin/bash -c "skaffold version | grep 'v2.0.2'"

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults