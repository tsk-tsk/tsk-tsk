// 2> /dev/null; . $(curl -sL https://git.io/boot-tsk | sh); run; exit

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
