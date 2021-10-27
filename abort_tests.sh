#!/bin/bash
# This script tests Scudo error types [1] that lead to process abort. These
# cannot be tested within the standard test harness which does not support
# aborts. This script is expected to be run in the root of the rust-scudo
# workspace directory.
#
# [1] https://llvm.org/docs/ScudoHardenedAllocator.html#error-types

cargo build --release --bin crash || exit 1

# Run the `crash` binary with the first arg. This binary will crash.
# If the second arg is present in the crash message, the test passes.
function run_test {
  tmp=$(mktemp)
  target/release/crash $1 2>$tmp
  if grep -q "$2" $tmp
  then
    echo "Test '$2' pass"
  else
    echo "Test '$2' failed"
    exit 1
  fi
}

run_test double_free "invalid chunk state"
run_test misaligned_ptr "misaligned pointer"
run_test corrupted_chunk_header "corrupted chunk header"

echo "All tests pass"