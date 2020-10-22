#!/bin/bash

testClassMatchesScriptName() {
  {
    preamble offline
    echo 'object Easy extends App { println("ok") }'
  } | saveAsScript "${wd}/Easy.scala"

  bash -c "${wd}/Easy.scala" > "${standard_output_file}" 2> "${standard_error_file}"
  exit_code=$?

  assertScriptSuccessful
  assertStandardErrorEmpty
  assertStandardOutputEquals "ok"
}

testClassMatchesScriptNameButThereIsPackage() {
  {
    preamble offline
    echo '
package app
object Easy extends App { println("ok") }'
  } | saveAsScript "${wd}/Easy.scala"

  source ~/.tsk/tsk-local "${wd}/Easy.scala"

  assertEquals "app.Easy" "$(get_main_class)"

}

testClassAndScriptNameMismatch() {
  {
    preamble offline
    echo 'object PieceOfCake extends App { println("ok") }'
  } | saveAsScript "${wd}/Easy.scala"

  source ~/.tsk/tsk-local "${wd}/Easy.scala"

  assertEquals "PieceOfCake" "$(get_main_class)"
}

oneTimeSetUp() {
  outputDir="${SHUNIT_TMPDIR}/output"
  mkdir "${outputDir}"
  standard_output_file="${outputDir}/stdout"
  standard_error_file="${outputDir}/stderr"
  wd="${SHUNIT_TMPDIR}"

  {
    preamble offline
    echo 'object Easy extends App { println("ok") }'
  } | saveAsScript "${wd}/Easy.scala"

  bash -c "${wd}/Easy.scala" > "${standard_output_file}" 2> "${standard_error_file}"
}

. ./test/helpers.sh
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ./test/shunit2
