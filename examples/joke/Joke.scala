package app /* 2> /dev/null
tsk_version=0.0.6; t="${HOME}/.tsk/tsk-${tsk_version}"; tsk_log="${TMPDIR:-"/tmp"}/tsk-$$.log"
[ ! -e $t -o "$tsk_version" == "trunk" ] && (u="https://raw.githubusercontent.com/tsk-tsk/tsk-tsk/${tsk_version}/tsk"; mkdir -p $(dirname $t); wget -O $t $u || curl -fLo $t $u) >> "${tsk_log}" 2>&1
. $t

verbose=true

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
