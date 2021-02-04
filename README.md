<div align="center">
<img src="https://raw.githubusercontent.com/tsk-tsk/tsk-tsk/trunk/doc/img/tsk-tsk-logo.png" alt="logo" width="20%" height="20%">

# TSK - The Scripting Kit

Truly Standalone Scala Scripts on Linux and Mac.

<img alt="AppVeyor CI" src="https://ci.appveyor.com/api/projects/status/github/tsk-tsk/tsk-tsk?branch=trunk&svg=true">

</div>

Make your Scala programs instantly runnable just by prepending it with a special (IDE / tooling neutral) preamble.
The program becomes a self-installable-and-executable shell script,
that everybody can run on their systems without any prerequisites.


The preamble (shell commands disguised as Scala comments) ensures that the prerequisites (everything needed to compile and execute
the Scala program) get first downloaded and then used to run the program. Caching is used to skip unnecessary downloads and recompilations
after the program has been run already.


The users of the scripts don't need to install or even know about JVM, SBT or any of the common tooling related to Scala programming.
This makes TSK-powered scripts ideal for situations in which Scala would be normally rejected because of the installation complexity
and set up overhead.

<div align="center">
<img src="https://raw.githubusercontent.com/tsk-tsk/tsk-tsk/trunk/doc/img/simple-demo.gif" alt="demo">
</div>

## Use TSK when
  - you've done your exploration with Ammonite / Polynote / Worksheets / Scala Fiddle / Scastie
    and want to put your findings into work
  - you want the result quickly: going for a proper build tool would be an overkill at this stage
  - but at the same time you want full IDE support and good development experience
  - you want the script to be useful not only to you, or to your Scala developer colleagues, but also to those
    data science and Python experts next door, who may not really know (or care for) JVM, Scala or related tooling
  - you don't want to have to care if the target system (colleague's laptop, CI server, Kubernetes pod)
    has everything installed already

So TSK will be great for:
  - that small script you will use to automate the common task in your company, especially if the users are
    not really into the JVM / Scala world
  - the actually-runnable example code that demonstrates features of your library
  - that little diagnostic program that you'll run inside a problematic Kubernetes pod
    to figure out what's happening
  - that quick prototype that you want to experiment with, before deciding if it would pay off to invest into a proper
    build configuration, CI setup and other software-engineery things like that
  - that small Scala program you want to play with while learning Scala features, before you decide to learn about
    JVMs, build tools and other distractions
    
## Don't use TSK when
  - you just want to play with Scala syntax, to explore some individual API methods, to test some smaller components,
    to perform some quick computations: for these purposes use any of the great Scala exploratory tools like
    [Ammonite REPL](http://ammonite.io/#Ammonite-REPL), [Polynote](https://polynote.org/), [Scala Worksheets](https://www.jetbrains.com/help/idea/work-with-scala-worksheet-and-ammonite.html#worksheet_actions), [Scala Fiddle](https://scalafiddle.io/), [Scastie](https://scastie.scala-lang.org/)
  - you're starting a new project that you already know is going to be a bigger thing, in that case go straight for a
    proper build tool, like [SBT](https://www.scala-sbt.org/) or [Mill](http://www.lihaoyi.com/mill/)
  - you want to rely on features of build tools, like compiler plugins, custom warning settings, multi-projects,
    test frameworks, code coverage measurements, etc.
  - you don't mind spending an extra effort to provide the best possible experience for your end users: in that case
    use the respective system's package management software or provide an appropriate platform-dependent installer
    like [IntelliJ IDEA](https://www.jetbrains.com/idea/download/) has
  - or, in general, when other Scala tools work well for your use-cases already

## Example

Say you've got some unstructured text file containing URL addresses and that you need to extract unique URLs.
Maybe you thought of using grep for that - but on a closer inspection URLs are quite involved beasts!
With all the query parameters, escaping etc. the regular expression may be difficult to get right
(let alone the readability of the end result). You would be better off using some proper URL validation method,
as typically found in programming languages. Ideally the language would be suitable for scripting,
so it'd be straightforward to write and run a program without you (and your users) having to fight tooling / dependencies.


Luckily Scala is one of the languages in which URL validation is available (within the standard library via Java SDK)
and with help of this project it is well suited for scripting as well. You can make a runnable
URLGrep script using Scala and TSK in a couple of minutes by following the steps below:

1. Save the following snippet into `URLGrep.scala` file (or [download it](https://raw.githubusercontent.com/tsk-tsk/tsk-tsk/trunk/examples/urlgrep/URLGrep.scala)):
```scala
// 2> /dev/null; source $(curl -sL https://git.io/boot-tsk | sh); run; exit

object URLGrep {

  def main(args: Array[String]) = {
    val urls = for {
      line  <- io.Source.stdin.getLines()
      token <- line.split("\\s+")
      clean <- token.split("[\"']")
      if util.Try(new java.net.URL(clean)).isSuccess
    } yield clean
    urls.toSet.toSeq.sorted.foreach(println)
  }

}
```
2. Set the executable bit:
```shell
chmod +x URLGrep.scala
```

Voilà! Your script is good to go. Pipe some text to its standard input to try it out:
```shell
echo "something something http://google.com" | ./URLGrep.scala
curl https://scala-lang.org | ./URLGrep.scala
```

The first run will take quite long (maybe even a couple of minutes) because TSK needs to download
several dependencies in the background first. The second and next runs will be quick, because
everything is cached on disk already.

One nice thing is that no matter on which Linux or Mac system you run it, it will work, as long they have `curl` or `wget` installed.
Think - you can pass that script to your coworkers, it'll work without any cumbersome tool installation needed.
The same for Docker containers - as long the image has `curl` / `wget`, your program will work there.

The above example is meant to whet your appetite by demonstrating some useful basics,
but the real fun begins with external libraries that can come from both public and company-private repositories.

Make sure you glance over the features section and also see [the wiki](https://github.com/tsk-tsk/tsk-tsk/wiki) for 
some guidance and explanations that go into more detail.
You can also play with the attached [examples](https://github.com/tsk-tsk/tsk-tsk/tree/trunk/examples) to see
various features of TSK in action.

## Main features

- The simplest possible workflow: you write the script, and you make it executable. That's it.
The initial script run downloads those of the required dependencies that don't exist on the machine yet.
- All Scala and Java libraries available, as long they are in some Maven or Ivy repository (internal corporate
repositories requiring credentials and/or proxies are supported as well - use your in-house components in your scripts)
- Regular Scala, without any syntax that'd confuse standard tooling (editable without red squiggles in IntelliJ IDEA).
  When your script grows somewhat, but not to a degree when it'd need a full-blown project, split it into separate files
  with all Scala constructs (like packages) working as expected
- Minimal prerequisites - apart from a working internet connection you only need `wget` or `curl`.
- Support for:
  - macOS (tested on AppVeyor, also had some positive user reports)
  - fresh Docker images of the following Linux distributions:
    - [Alpine](https://www.alpinelinux.org/), [Arch Linux](https://archlinux.org/), [Fedora](https://getfedora.org/) out of the box (they've got `curl` / `wget`)
    - [Debian](https://www.debian.org/), [Ubuntu](https://ubuntu.com/) after you install `curl`
  - most likely your Linux distribution even without root permissions as long you've installed `curl` or `wget`
- Experimental support for Ammonite scripts (use `run_with_ammonite` instead of `run`)

## Planned features

- Easy migration to a full-blown Scala project when the script grows.
The script is valid Scala, so the existing tooling handles it perfectly well - the TSK-specific parts are hidden
from the Scala compiler within the Scala comment block. TSK will be able to generate SBT and Mill projects
- Compilation of your script to a native binary (with GraalVM) to reduce the script's memory footprint and startup time
- Robust handling of errors made in the shell part (preamble)

## Acknowledgements

TSK stands on the shoulders of giants. Kudos to all authors and contributors of the following technologies:

- [Scala](https://www.scala-lang.org/), which is my favorite programming language
- [Ammonite](http://ammonite.io/) - the best Scala REPL, which also pioneered Scala scripting capabilities
- [Coursier](https://get-coursier.io/), which made it super-easy to manage Scala and Java dependencies
- [Bloop](https://scalacenter.github.io/bloop/), which provides great compilation and IDE interoperation features
- Unix, with fantastic scripting capabilities

## Special thanks

- To that [ScalaPolis2016](https://web.archive.org/web/20170606154012/http://konf.scalapolis.pl/#slot3) attendee, who noticed, that it's possible for a file to be both valid Scala and valid shell.
- To those of the [ScalaPolis2016](https://web.archive.org/web/20170606154012/http://konf.scalapolis.pl/#slot3) and [FunctionalTricity 28.04.2016](https://www.meetup.com/FunctionalTricity/photos/26928835/449436348/) attendees, who have appreciated my points and to those who made fun of them.
I enjoyed our conversations very much :smile:
- To the wonderful organizers of the mentioned events for having me and for still wanting me to speak! :wink:
