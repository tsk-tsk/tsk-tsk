# The Scripting Kit

Truly Standalone Scala Scripts on Linux and Mac

## Overview

This shell library lets you write Scala scripts that can run completely standalone on Linux and macOS
thanks to the automatic background download and installation of all their dependencies: libraries and even Java SDK.
You can paste the script into an email or a chat and your collegues will be able to run it without any tools,
similarly you can shell into a k8s pod / docker container (or ssh to a machine) and then simply run the script there
without any up-front setup.

## Main features

- Minimal prerequisites - apart of a working internet connection you only need these common programs: `bash`, `curl`, `unzip`, `which` and `zip`
- The simplest possible workflow: you write the script and you make it executable. That's it.
The initial script run downloads those of the required dependencies that don't exist on the machine yet.
- Regular Scala, without any syntax that'd confuse standard tooling (editable without red squiggles in IntelliJ IDEA).
When your script grows somewhat, but not to a degree when it'd need a full-blown project, split it into separate files
with all Scala constructs (like packages) working as expected
- Use all Scala and Java libraries you need or want, as long they are in a public repository

## Planned features

- Repositories that require credentials; internet access via proxy
- Easy migration to a full-blown Scala project when the script grows.
The script is valid Scala so the existing tooling handles it perfectly well - the TSK-specific parts are hidden
from the Scala compiler within the Scala comment block. TSK will be able to generate SBT and Mill projects
when

## Word of caution

This is a very early release and there will be rough edges, especially around different versions of Java, Scala
and of tools used internally (Bloop, Coursier).

## Example

Here is all you need to write a Scala script, that displays a random programming joke fetched from a JSON API.
It demonstrates usage of an some external libraries (sttp and circe):

```scala
package app /* 2> /dev/null
tsk_version=trunk; t="${HOME}/.tsk/tsk-${tsk_version}"; tsk_log="${TMPDIR:-"/tmp"}/tsk-$$.log"
[ ! -e $t -o "$tsk_version" == "trunk" ] && (u="https://raw.githubusercontent.com/tsk-tsk/tsk-tsk/${tsk_version}/tsk"; mkdir -p $(dirname $t); wget -O $t $u || curl -fLo $t $u) >> "${tsk_log}" 2>&1
. $t

dependencies='
  com.softwaremill.sttp.client::core:2.2.6
  com.softwaremill.sttp.client::circe:2.2.6
  io.circe::circe-generic:0.12.3
'

run "$@"; cat "${tsk_log}" >&2; exit 1 # */

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

## Supported platforms

- macOS (tested on AppVeyor, no reports from a fresh macOS system)
- fresh Docker images of the following Linux distributions:
  - out of the box: alpine, archlinux, fedora (they've got `curl` / `wget`)
  - after you install `curl`: debian, ubuntu
- most likely your Linux distribution even without root permissions as long you've got `bash`, `curl`, `unzip`, `which`, `zip`

## Things to watch for

1. Target environment - because the script file is at the same time Scala and Shell, the Scala `package` keyword
is going to be interpreted as a name of a program. On most environments (including a fresh Alpine/Ubuntu/macOS system)
no program with that name will exist and that's fine. Though if it happened to exist, then it would be run
at the beginning / instead of the script, potentially causing some undesired side-effects.
Please check the environment before running the script on a critical system.
2. Code formatters - they sometimes split the first line into `package` declaration and move the start of the comment
to the next line. What Scala interprets as a beginning of a comment block (`/*`) Shell expands to
`/bin /dev /etc /home ...`, treating the first thing there as a name of program to execute. If it's a directory
(the typical case) then it's fine, but if it happens, that the root directory contains a program that would appear at
the beginning of the `/*` expansion, like `/aaa-do-not-run /bin /dev /etc /home ...`, then some undesired side-effects
may occur.
3. TSK installing all dependencies takes time on a fresh system, so if you are preparing a Docker image that needs to
start up quickly, do not only ADD your script on it, but also RUN your script in some no-operation mode
(for example with `--help` or `--version`, depends on your script).
This way the dependencies will be installed to the image already during the build and your container will start up fast.

## Acknowledgements

TSK stands on the shoulders of giants. Kudos to all authors and contributors of the following technologies:

- Scala, which is my favorite programming language
- Ammonite, the best Scala REPL, which also pioneered Scala scripting capabilities
- Coursier, which made it super-easy to manage Scala and Java dependencies
- Bloop, which provides great compilation and IDE interoperation features
- SDKMAN! which greatly simplified management of Java SDKs
- Unix, with fantastic scripting capabilities

## Special thanks

- To that ScalaPolis2016 attendee, who noticed, that it's possible for a file to be both valid Scala and valid shell.
- To those of the ScalaPolis2016 and FunctionalTricity 28.04.2016 attendees, who have appreciated my points and to those who made fun of them.
I enjoyed our conversations very much :)
- To the wonderful organizers of the mentioned events for having me and for still wanting me to speak! ;)
