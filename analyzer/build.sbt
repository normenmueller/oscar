lazy val analyzer = (project in file(".")).
  settings(
    name := "oscar.analyzer",
    scalaVersion := "2.11.8",
    scalacOptions ++= Seq("-deprecation", "-encoding", "UTF-8", "-feature", "-unchecked"), 
    resolvers += Resolver.mavenLocal, 
    libraryDependencies ++= Seq(
      "mdpm.sql" % "oscar.parser" % "0.1.0",
      "org.scalatest" %% "scalatest" % "3.0.0" % "test"
    ),
    unmanagedSourceDirectories in Compile <<= (scalaSource in Compile)(Seq(_)),
    unmanagedSourceDirectories in Test <<= (scalaSource in Test)(Seq(_)),
    EclipseKeys.eclipseOutput := Some("target")
  )
