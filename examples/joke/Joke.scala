/// TSK - The Scripting Kit      2> /dev/null \\\
/*
verbose=true
dependencies='
  com.softwaremill.sttp.client::core:2.2.6
  com.softwaremill.sttp.client::circe:2.2.6
  io.circe::circe-generic:0.12.3
'
v=0.1.1; . $(u=git.io/boot-tsk-$v; (cat ~/.tsk/boot-tsk-$v || curl -sfL $u || wget -qO - $u) | v=$v sh); run
 */

import io.circe.generic.auto._
import sttp.client.circe._
import sttp.client.quick._

case class JokeResponse(
    setup: String,
    delivery: String
)

object Joke extends App {
  val response = quickRequest
    .get(
      uri"https://sv443.net/jokeapi/v2/joke/Programming?blacklistFlags=nsfw,racist,political,sexist,religious&type=twopart"
    )
    .response(asJson[JokeResponse])
    .header("User-Agent", "curl/7.68.0", replaceExisting = true) // sv443.net bans Java apparently
    .send()
    .body
  response match {
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
