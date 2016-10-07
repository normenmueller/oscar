package mdpm
package object oscar {

  type Schema = String

  type Table = String

  type Name = String

  type Alias = String

  type Seq[+A] = scala.collection.immutable.Seq[A]
  val Seq = scala.collection.immutable.Seq

}
