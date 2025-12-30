set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_FILE="$ROOT_DIR/tests/bank_loan_tests.pl"

if command -v swipl >/dev/null 2>&1; then
  echo "swipl found — running tests"
  swipl -q -s "$TEST_FILE" -g run_tests -t halt
  exit $?
fi

echo "swipl (SWI-Prolog) not found on PATH. Attempting to install (Debian/Ubuntu only)."
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must use sudo to install packages. You will be prompted for your password." 
  sudo apt-get update
  sudo apt-get install -y swi-prolog
else
  apt-get update
  apt-get install -y swi-prolog
fi

echo "Running tests"
swipl -q -s "$TEST_FILE" -g run_tests -t halt
