#!/bin/bash

testUsingSystemJavaShouldNotDownloadJVM() {
  {
    preamble shunit 'java_version=system'
    echo 'object PieceOfCake extends App { println("ok") }'
  } | saveAsScript "${wd}/Easy.scala"

  (# Using a sub-shell to keep these variables scoped
    export JAVA_HOME="$javaHome"
    # shellcheck disable=SC2030
    export PATH="$javaHome/bin:$PATH"
    export HOME="$homeDir"
    export COURSIER_JVM_CACHE="$coursierJvms"
    # shellcheck disable=SC2164 # wd is known to exist
    cd "$wd"
    bash -c "${wd}/Easy.scala" > "${standard_output_file}" 2> "${standard_error_file}"

    assertStandardOutputEquals "ok"
    # shellcheck disable=SC2012
    assertEquals "Should have installed coursier without jvm" "1" "$(ls -1 "$HOME"/.tsk/cs-*-jvmless | wc -l)"
    # shellcheck disable=SC2012
    assertEquals "Should not have download any jvm" "0" "$(ls -1 "$COURSIER_JVM_CACHE"/ | wc -l)"
  )

}

oneTimeSetUp() {
  javaHome="$(localJavaHome)"
  coursierJvms="${SHUNIT_TMPDIR}/coursier-jvms"
  homeDir="${SHUNIT_TMPDIR}/home"
  outputDir="${SHUNIT_TMPDIR}/output"
  standard_output_file="${outputDir}/stdout"
  standard_error_file="${outputDir}/stderr"

  mkdir -p "$coursierJvms" "$homeDir" "$outputDir"
  wd="${SHUNIT_TMPDIR}"
}

tearDown() {
  echo "This is contents of standard error"
  echo "----------------------------------"
  cat "${standard_error_file}"
}

. ./test/lib/helpers.sh
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ./test/lib/shunit2
