testEchoToStandardOutput() {

  # set up
  base_tmpdir="$(mktemp -d)"
  outputDir="${base_tmpdir}/output"
  mkdir "${outputDir}"
  standard_output_file="${outputDir}/stdout"
  standard_error_file="${outputDir}/stderr"

  wd="${base_tmpdir}/$(date +%H-%M-%S-%N)"
  mkdir -p "${wd}"


  # Given a simple script

  # shellcheck disable=SC2016
  scala_script='object Hello extends App { println("hello") }'
  preamble shortest > "${wd}/Hello.scala"
  echo "${scala_script}" >> "${wd}/Hello.scala"
  chmod +x "${wd}/Hello.scala"

  # When it's run
  $0 -c "${wd}/Hello.scala" > "${standard_output_file}" 2> "${standard_error_file}"
  exit_code=$?

  # Then the exit code is zero and "hello" gets printed on standard output
  tearDown

  checkScriptExitCode() {
    if [ $exit_code -eq 0 ]
    then
      true
    else
      echo "Incorrect exit code: $exit_code"
  }

  checkScriptExitCode && checkStandard
  assertScriptSuccessful
  assertStandardErrorContains Total
  assertStandardOutputEquals "hello"
}

tearDown() {
  echo "This is contents of standard error"
  echo "----------------------------------"
  cat "${standard_error_file}"
}

. test/lib/helpers.sh

testEchoToStandardOutput
