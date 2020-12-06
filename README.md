<div align="center">
<img src="https://raw.githubusercontent.com/tsk-tsk/tsk-tsk/trunk/doc/img/tsk-tsk-logo.png" alt="logo" width="20%" height="20%">

# TSK - The Scripting Kit
<img alt="AppVeyor CI" src="https://ci.appveyor.com/api/projects/status/github/tsk-tsk/tsk-tsk?branch=trunk&svg=true">

Truly Standalone Scala Scripts on Linux and Mac.
</div>

<hr>
Prepend your Scala program with a specially crafted preamble to turn it into a self-installable-and-executable shell script,
that everybody can run on their systems without any prerequisites.

The preamble (shell commands disguised as Scala comments) ensures that the prerequisites (everything needed to compile and execute
the Scala program) get first downloaded and then used to run the program. Caching is used to skip unnecessary downloads and recompilations
after the program has been run already.

The users of the scripts don't need to install or even know about JVM, SBT or any of the common tooling related to Scala programming.
This makes TSK-powered scripts ideal for situations in which Scala would be normally rejected because of the installation complexity
and set up overhead.

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
