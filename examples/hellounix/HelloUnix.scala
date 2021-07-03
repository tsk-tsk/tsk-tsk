// 2> /dev/null; native=true; . $(curl -sL https://git.io/boot-tsk | sh); run; exit

object HelloUnix extends App {

  args.toList match {
    case "cat" :: _ => Console.in.lines().forEach(Console.out.println _)
    case "cat-err" :: _ => Console.in.lines().forEach(Console.err.println _)
    case "echo" :: rest => Console.out.println(rest.mkString(" "))
    case "env" :: variableName :: rest =>
      if (System.getenv.containsKey(variableName)) {
        Console.out.println(System.getenv(variableName))
      } else {
        Console.err.println(s"$variableName is not set")
      }
    case "property" :: propertyName :: _ =>
      System.getProperty(propertyName) match {
        case v if v != null => Console.out.println(v)
        case null => Console.err.println(s"$propertyName is not set")
      }
    case "properties" :: Nil => System.getProperties().list(System.out)
    case "exit" :: codeStr :: _ =>
      scala.util.Try(codeStr.toInt).toOption match {
        case Some(exitCode) => System.exit(exitCode)
        case None =>
          Console.err.println(s"Invalid exit code: ${codeStr}")
          System.exit(1)
      }
    case _ =>
      Console.err.println("Available commands: cat, cat-err, echo [ARGS], env VARIABLE_NAME, property PROPERTY_NAME, properties, exit CODE")
  }

}
