<div align="center">
<img src="https://raw.githubusercontent.com/tsk-tsk/tsk-tsk/trunk/doc/img/tsk-tsk-logo.png" alt="logo" width="20%" height="20%">
</div>

# TSK - The Scripting Kit

Truly Standalone Scala Scripts on Linux and Mac. Add a special short comment to the top of your Scala program
and run it without having to install anything. Pass the script to people who know nothing about Scala, JVM, SBT,
it will run for them instantly.
All required libraries and tools get downloaded in the background on the first run.

![](doc/img/simple-demo.gif)

## Example

Here is all you need to write a Scala script, that displays a random programming joke fetched from a JSON API.
It demonstrates usage of an some external libraries (sttp and circe):

```scala
// 2> /dev/null \
/*
source $(curl -sL git.io/boot-tsk | sh)

dependencies='
  com.softwaremill.sttp.client::core:2.2.6
  com.softwaremill.sttp.client::circe:2.2.6
  io.circe::circe-generic:0.12.3
'

run
*/

import sttp.client.quick._
import sttp.client.circe._
import io.circe.generic.auto._

case class JokeResponse(
  setup: String,
  delivery: String
)

object Joke extends App {
  quickRequest
    .get(uri"https://sv443.net/jokeapi/v2/joke/Programming?blacklistFlags=nsfw,racist,political,sexist,religious&type=twopart")
    .response(asJson[JokeResponse])
    .header("User-Agent", "curl/7.68.0", replaceExisting = true)  // sv443.net bans Java apparently
    .send()
    .body match {
    case Right(JokeResponse(setup, delivery)) =>
      println(setup)
      Thread.sleep(2000)
      for (i <- (3 to 1 by -1)) {
        println(s"${i}...")
        Thread.sleep(300)
      }
      println(delivery)
    case Left(_) =>
      println("Sorry, no joke this time")
  }
}
```

## Main features

- Minimal prerequisites - apart of a working internet connection you only need `wget` or `curl`.
- The simplest possible workflow: you write the script and you make it executable. That's it.
The initial script run downloads those of the required dependencies that don't exist on the machine yet.
- Regular Scala, without any syntax that'd confuse standard tooling (editable without red squiggles in IntelliJ IDEA).
When your script grows somewhat, but not to a degree when it'd need a full-blown project, split it into separate files
with all Scala constructs (like packages) working as expected
- Use all Scala and Java libraries you need or want, as long they are in a maven or ivy repository (internal corporate
repositories requiring credentials and/or proxies are supported as well)
- support for:
  - macOS (tested on AppVeyor, also had some positive user reports)
  - fresh Docker images of the following Linux distributions:
    - out of the box: alpine, archlinux, fedora (they've got `curl` / `wget`)
    - after you install `curl`: debian, ubuntu
  - most likely your Linux distribution even without root permissions as long you've installed `curl` or `wget`
- Experimental support for Ammonite scripts (use `run_with_ammonite` instead of `run`)

## Planned features

- Customizable JVM version (at the time 1.8 is used)
- Easy migration to a full-blown Scala project when the script grows.
The script is valid Scala so the existing tooling handles it perfectly well - the TSK-specific parts are hidden
from the Scala compiler within the Scala comment block. TSK will be able to generate SBT and Mill projects
- Robust error handling

## How does it work

Running of a Scala program directly by a shell is possible provided that the Scala file is made executable
(`chown +x YourProgram.scala`) and that it is at the same time valid shell and valid Scala program.

That can be achieved by starting the file with `// 2> /dev/null \` line, then having a `/*` line, then some shell
code in the following lines and then a `*/` line, after which the actual Scala source code follows - example:

```scala
// 2> /dev/null \
/*
source $(curl -sL git.io/boot-tsk | sh)
run
 */
object Hello extends App { println("Hello") }
```

This way the script stays valid Scala (first line: an inline comment, next lines: a block comment, rest: regular Scala)
and at the same time it can be usefully run by the shell - here is how shell interprets it:
1. This first line is an invalid attempt of execution of a program (because `//` is not a file - it is the top-level
   root directory). The shell normally displays a respective error, but the `2> /dev/null` part suppresses it.
   The last character of the line (`\`) indicates that the line hasn't yet ended and it continues at the next line.
2. The second line (`/*`) is treated as `//` "program"'s arguments and is being expanded according to the shell rules
   into something like `/bin /boot ... /usr /var` but since the "program" can't be run it does not matter.
3. The third line (starting with `source`) brings into the scope of the current shell session multiple variable
   and function definitions (the actual TSK code), including the default values for settings like Scala, Coursier
   and Bloop versions. Nothing big like JVM, Coursier, Bloop or libraries gets installed yet at this point, the only
   side effect is that the TSK is downloaded to the `.tsk` directory under the user's home.
4. The lines preceding the `run` helper function call define all settings required by the Scala program (like list of
   libraries that the program uses). The list of all available settings is documented in the next section.
5. The `run` helper function prepares the program for the execution (which includes making sure all the tools
   and libraries are downloaded) and finally executes the program with a Java Virtual Machine. When the Scala program
   ends running, the script exits, because `run` is using `exec` internally (script process gets replaced by JVM
   process), so the shell won't see (and won't be confused) the Scala source code, nor by the closing of the Scala comment
   block (`*/`).

TSK relies on the fact, that by default shells don't stop at the first error (the attempt of execution of invalid `//`
program). This, combined with another shell feature (`\` at the end of the line) allows one to create a working shell
script, which is at the same time fine Scala for the standard, unmodified Scala compiler.

## Variable reference

All variables defined after sourcing TSK and before the `run` function invocation will override the defaults.
Whenever a variable is described as a list, then it's a string with whitespace (and/or newline) separated elements, for
example you may declare script dependencies either as `dependencies='foo::bar:1.0.0 baz::quix:0.3.1'` or as:
```shell
dependencies='
  foo::bar:1.0.0
  baz::quix:0.3.1
'
```
equivalently. You can also take advantage of the fact, that everything up to (and including) the `run` invocation is
shell script, so without the double-quotes things are evaluated according to shell rules. Say you've got a library with
multiple components, sharing a single version. You may define it as a separate variable and refer to it within another
expression:
```shell
sttp_version=2.2.6
dependencies="
  com.softwaremill.sttp.client::core:$sttp_version
  com.softwaremill.sttp.client::circe:$sttp_version
  io.circe::circe-generic:0.12.3"
```

Variable | Default |Description
---------|---------|-----------
**scala_version** | 2.12.12 | version of Scala to be used in compilation and in resolution of libraries (in order to translate `group::artifact:version` to `group:artifact_scalamajordotminorversion:version`)
sources | | Additional Scala source files (and directories) that the script uses (and therefore need to be compiled together with it). List of file/directory names, may also contain shell glob patterns. Example: `lib/*.scala`
**dependencies** | | dependency list specification in format used by [Coursier](https://get-coursier.io/) (`group::artifact:version` or `group:artifact_scalamajordotminorversion:version`) separated by whitespace, including newlines. Example: `'com.typesafe.play::play-json:2.8.2 org.tpolecat::doobie-core:0.9.0'`
repositories | | list of custom artifact repository URLs, which are used in dependency resolution for artifacts that can't be found in the [well-known](https://get-coursier.io/docs/other-repositories) public maven repositories (which are being used always by default). A whitespace (including newline) separated list of URLs. The values listed here are passed to `-r` option of Coursier ([see here for more information](https://get-coursier.io/docs/other-repositories))
forced_versions | | list of artifacts in explicitly stated versions that are to be used instead of the results of the automatic dependency resolution process. Commonly used when you depend on an older version of a library and the newer version is not backward compatible but some of the other dependencies pulls it in transitively. In `group::artifact:version` format (list separated by whitespace, including newlines) as the values are passed to the `--force-version` option of Coursier.
exclusions | | List of excluded artifacts in format: `organization:name` (note, *no version* here). The list needs to be separated by whitespace including newlines. Used in cases the artifact resolution process transitively pulls in something that you don't want. Internally the entries are transformed into Coursier's option: `--exclude`.
main_class | | name of the main class (script entrypoint). If not given it's assumed to be `package.name.ScriptFileNameWithoutScalaExtension`, where `package.name` is the name used in the first `package` declaration found in the file (in other words, you can rely on the default if you name your main class the same as the script file and ensure it has a `main` method, either directly or inherited/mixed-in from something like [`App`](https://www.scala-lang.org/api/current/scala/App.html))
coursier_version | `v2.0.0-RC6-24` | version of [Coursier](https://get-coursier.io/), the workhorse for JVM and library fetching
bloop_version | `2.12:1.4.4-2-f9fd96b8` | version of [Bloop](https://scalacenter.github.io/bloop/) which is used to compile the Scala classes
COURSIER_OPTS | | options passed to the Coursier binary. Typically you put [network proxy](https://get-coursier.io/docs/other-proxy.html#cli) and private repository [credentials configuration](https://get-coursier.io/docs/other-credentials) here.
JAVA_OPTS | | options passed to the JVM invocation when the compiled program is being run. A good place to set memory limits.
verbose | `false` | set `true` for more insight into what happens in the background (written to standard error stream) or `false` to only see fatal errors. In case of serious troubles, in addition to `verbose=true` also add `set -x` in a separate line.

## Things to watch for

1. Smart editors that automatically insert some code to the top of the file (like automatic package declaration or
   import organization) - if the `import` or `package` keyword gets put before the TSK special comment, then
   shell will try to run them. Usually nothing bad will happen apart from some errors being displayed to standard error.
   But if `import` or `package` programs exist on the system, then they will be run.
2. Running a TSK-powered script may take some time on a fresh system, because a number of dependencies, including some
   big ones need to be downloaded during first run. Be especially mindful that when you prepare a Docker image which
   needs to be starting up quickly, do not only ADD your script on it, but also RUN your script in some no-operation
   mode (for example with `--help` or `--version`, depends on your script).
   This way the dependencies will be installed to the image already during the build and your container will start up fast.

## Acknowledgements

TSK stands on the shoulders of giants. Kudos to all authors and contributors of the following technologies:

- Scala, which is my favorite programming language
- Ammonite, the best Scala REPL, which also pioneered Scala scripting capabilities
- Coursier, which made it super-easy to manage Scala and Java dependencies
- Bloop, which provides great compilation and IDE interoperation features
- Unix, with fantastic scripting capabilities

## Special thanks

- To that ScalaPolis2016 attendee, who noticed, that it's possible for a file to be both valid Scala and valid shell.
- To those of the ScalaPolis2016 and FunctionalTricity 28.04.2016 attendees, who have appreciated my points and to those who made fun of them.
I enjoyed our conversations very much :)
- To the wonderful organizers of the mentioned events for having me and for still wanting me to speak! ;)
