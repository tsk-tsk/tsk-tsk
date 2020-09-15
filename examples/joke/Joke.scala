package app /* 2> /dev/null
v=0.0.18; source $(u=https://git.io/boot-tsk-$v; (cat ~/.tsk/boot-tsk-$v || curl -fL $u || wget -O - $u) | v=$v sh)

verbose=true

dependencies='
  com.softwaremill.sttp.client::core:2.2.6
  com.softwaremill.sttp.client::circe:2.2.6
  io.circe::circe-generic:0.12.3
'

run */

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
