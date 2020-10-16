export tsk_version="$(git describe --exact-match 2> /dev/null || git rev-parse HEAD)"

assertScriptSuccessful() {
  assertEquals "Script was expected to succeed, but it failed" 0 $exit_code
}

assertScriptFailed() {
  assertNotEquals "Script was expected to fail, but it succeeded" 0 $exit_code
}

assertStandardErrorEmpty() {
  assertTrue "Standard error was expected to be empty, but it was:\n$(cat "${standard_error_file}")" "[ -s '${standard_error_file}' ]"
}

assertStandardErrorContains() {
  assertContains "$(cat "${standard_error_file}")" "${1}"
}

assertStandardOutputContains() {
  assertContains "$(cat "${standard_output_file}")" "${1}"
}

assertStandardOutputEquals() {
  assertEquals "Standard output differs from expected" "${1}" "$(cat "${standard_output_file}")"
}
