#!/bin/sh

assertScriptSuccessful() {
  assertEquals "Script was expected to succeed, but it failed" 0 $rtrn
}

assertStandardErrorEmpty() {
  assertTrue "Standard error was expected to be empty, but it was:\n$(cat "${stderrF}")" "[ -s '${stderrF}' ]"
}

assertStandardErrorContains() {
  grep -q "${1}" "${stderrF}" || fail "Content [${1}] was not foud in:
$(cat "${stderrF}")"
}

assertStandardOutputEquals() {
  assertEquals "Standard output differs from expected" "${1}" "$(cat "${stdoutF}")"
}

testEchoToStandardOutput() {
  # Given a simple script

  # shellcheck disable=SC2016
  preamble='// 2> /dev/null; source $( curl -L git.io/boot-tsk | sh ); run'
  echo "${preamble}" > "${wd}/Hello.scala"
  echo 'object Hello extends App { println("hello") }' >> "${wd}/Hello.scala"
  chmod +x "${wd}/Hello.scala"

  # When it's run
  bash -c "${wd}/Hello.scala" > "${stdoutF}" 2> "${stderrF}"
  rtrn=$?

  cp "${stderrF}" ./err-delme

  # Then the exit code is zero and "Hello" gets output
  assertScriptSuccessful
  assertStandardErrorContains Total
  assertStandardOutputEquals "hello"
}

oneTimeSetUp() {
  # run the HelloUnix script for the first time, so everything gets initialized
  # Let each test use a different directory to start fresh and not mix compiled classes
  # - the directory will be wd

  # we shouldn't have to replace the script versions manually
  # - the $(git rev-parse HEAD) should give us the commit and we should use it as a version
  # and also not download boot-tsk from git.io because let's not count on tags only
  # but straight from the rawgitusercontent.
  # This obviously means that the preambles need to be generated dynamically basing on version.

  # :( Looks like the preambles used in tests will look completely differently than ones for prod.
  # UNLESS
  # we replace v=0.1.1 with v=co1231239273462ocfff11b
  # u=git.io-$v with u=https://rawusercontent....
  # YES!!! :)

  outputDir="${SHUNIT_TMPDIR}/output"
  mkdir "${outputDir}"
  stdoutF="${outputDir}/stdout"
  stderrF="${outputDir}/stderr"
}

setUp() {
  wd="${SHUNIT_TMPDIR}/$(date +%H-%M-%S-%N)"
  mkdir -p "${wd}"
}

tsk_version="$(git describe --exact-match 2> /dev/null || git rev-parse HEAD)"


# Load and run shUnit2.
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ./test/shunit2
