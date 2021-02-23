#!/bin/bash

testEchoToStandardOutput() {
  # Given a simple script

  # shellcheck disable=SC2016
  scala_script='object Hello extends App { println("hello") }'
  preamble shortest      > "${wd}/Hello.scala"
  echo "${scala_script}" >> "${wd}/Hello.scala"
  chmod +x "${wd}/Hello.scala"

  # When it's run
  bash -c "${wd}/Hello.scala" > "${standard_output_file}" 2> "${standard_error_file}"
  exit_code=$?

  # Then the exit code is zero and "hello" gets printed on standard output
  assertScriptSuccessful
  assertStandardErrorContains Total
  assertStandardOutputEquals "hello"
}

oneTimeSetUp() {
  outputDir="${SHUNIT_TMPDIR}/output"
  mkdir "${outputDir}"
  standard_output_file="${outputDir}/stdout"
  standard_error_file="${outputDir}/stderr"
}

setUp() {
  wd="${SHUNIT_TMPDIR}/$(date +%H-%M-%S-%N)"
  mkdir -p "${wd}"
}

tearDown() {
  echo "This is contents of standard error"
  echo "----------------------------------"
  cat "${standard_error_file}"
}

. ./test/lib/helpers.sh
# Load and run shUnit2.
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ./test/lib/shunit2
