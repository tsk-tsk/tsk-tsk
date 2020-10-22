export tsk_version="$(git describe --exact-match 2> /dev/null || git rev-parse HEAD)"

emulateTskDownload() {
  ln -fs "$(pwd)/boot-tsk" ~/.tsk/boot-tsk-${tsk_version}
  ln -fs "$(pwd)/tsk" ~/.tsk/tsk-${tsk_version}
  ln -fs "$(pwd)/boot-tsk" ~/.tsk/boot-tsk-local
  ln -fs "$(pwd)/tsk" ~/.tsk/tsk-local
}

# Outputs tsk-tsk preamble from selected file (first argument)
# with VERSION replaced with current version
# and with SETTINGS replaced with given ones (second argument)
#
# All github links get replaced with raw.githubusercontent.com forms
# (to not have to rely on every version be exposed at git.io)
preamble() {
  sed "s/VERSION/${tsk_version}/g
       s/SETTINGS/${2}/g;" "./doc/preambles/${1}" | \
       sed "s|git.io/boot-tsk-${tsk_version}|raw.githubusercontent.com/tsk-tsk/tsk-tsk/${tsk_version}/boot-tsk|g"
}

saveAsScript() {
  cat > "${1}"
  chmod +x "${1}"
}

assertScriptSuccessful() {
  assertEquals "Script was expected to succeed, but it failed" 0 $exit_code
}

assertScriptFailed() {
  assertNotEquals "Script was expected to fail, but it succeeded" 0 $exit_code
}

assertStandardErrorEmpty() {
  assertEquals "Standard error was expected to be empty, but it was:\n[$(
    cat "${standard_error_file}")]" "${1}" "$(cat "${standard_error_file}")"
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
