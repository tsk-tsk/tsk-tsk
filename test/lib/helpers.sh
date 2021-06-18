export tsk_version="$(git describe --exact-match 2> /dev/null || git rev-parse HEAD)"
export tsk_bin="$(pwd)/tsk"

emulateTskDownload() {
  ln -fs "$(pwd)/boot-tsk" ~/.tsk/boot-tsk-${tsk_version}
  ln -fs "$(pwd)/tsk" ~/.tsk/tsk-${tsk_version}
  ln -fs "$(pwd)/boot-tsk" ~/.tsk/boot-tsk-local
  ln -fs "$(pwd)/tsk" ~/.tsk/tsk-local
}

localJavaHome() {
  systemJavaHome || coursierJavaHome
}

# Determine the java home from system java
systemJavaHome() {
  command -v java > /dev/null 2>&1 && java -XshowSettings:properties -version 2>&1 > /dev/null | grep 'java.home =' | sed 's/.*= //'
}

# When running system-java tests and the user/CI does not have a system java
# we get a default one with coursier.
coursierJavaHome() {
  ( # Use a subshell to prevent poluting env 
    unset JAVA_HOME
    # Create an empty script just to source tsk utils
    script_file="${SHUNIT_TMPDIR}/empty.sc"
    touch "$script_file"
    source "$tsk_bin" "$script_file"
    rm "$script_file"
    prepare_java 1>&2 # install default java via coursier
    PATH="$(p_with_custom_java)" systemJavaHome
  )
}


# Outputs tsk-tsk preamble from selected file (first argument)
# with the following replacements:
#
# TSK_BIN replaced with full path of local tsk script.
# VERSION replaced with current version
# SETTINGS replaced with given ones (second argument)
#
# All github links get replaced with raw.githubusercontent.com forms
# (to not have to rely on every version be exposed at git.io)
preamble() {
  sed "s|TSK_BIN|${tsk_bin}|g
       s/VERSION/${tsk_version}/g
       s/SETTINGS/${2}/g
       s|git.io/boot-tsk-${tsk_version}|raw.githubusercontent.com/tsk-tsk/tsk-tsk/${tsk_version}/boot-tsk|g
       s|git.io/boot-tsk-\\\$v|raw.githubusercontent.com/tsk-tsk/tsk-tsk/${tsk_version}/boot-tsk|g" \
      "./doc/preambles/${1}"
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
    cat "${standard_error_file}"
  )]" "${1}" "$(cat "${standard_error_file}")"
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
