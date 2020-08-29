package app /* 2> /dev/null
tsk_version=0.0.2; t="${HOME}/.tsk/tsk-${tsk_version}"
[ ! -e $t -o "$tsk_version" == "trunk" ] && (u="https://raw.githubusercontent.com/tsk-tsk/tsk-tsk/${tsk_version}/tsk"; mkdir -p $(dirname $t); wget -O $t $u || curl -fLo $t $u)
. $t

dependencies() {
  echo '
    com.softwaremill.sttp.client::core:2.2.6
    com.softwaremill.sttp.client::circe:2.2.6
    io.circe::circe-generic:0.12.3
  '
}

run "$@"
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
      Thread.sleep(3000)
      println(delivery)
    case Left(_) =>
      println("Sorry, not joke this time")
  }
}
