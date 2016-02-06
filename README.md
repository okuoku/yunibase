Yunibase
========

This is Yunibase, collection of R6RS/R7RS implementations to test [Yuni R6RS/R7RS portability library][].

Prebuilt images
===============

* [Linux Docker images][] on [Docker Hub][]
 * `okuoku/yunibase:testing` [![](https://badge.imagelayers.io/okuoku/yunibase:testing.svg)](https://imagelayers.io/?images=okuoku/yunibase:testing) - Ubuntu LTS
 * `okuoku/yunibase:testing-fedora` [![](https://badge.imagelayers.io/okuoku/yunibase:testing-fedora.svg)](https://imagelayers.io/?images=okuoku/yunibase:testing-fedora) - Fedora latest

Supported build environments
============================

 * [Linux Docker images][]
  * `okuoku/yunibuild:latest` - [Buildsystem based on Ubuntu LTS][]
  * `okuoku/yunibuild:latest-fedora` - [Buildsystem based on Fedora][]

Implementations
===============

|                |Standard  |[Stable][]|[Current][]    |Remarks                               |
|:---------------|:--------:|:--------:|:-------------:|:-------------------------------------|
|[Chibi-scheme][]|R7RS      |n/a       |Official GitHub|                                      |
|[Gauche][]      |R7RS      |0.9.4+    |Official GitHub|                                      |
|NMosh           |R6RS+R7RS-|current   |not yet        |TESTFAIL                              |
|[Sagittarius][] |R6RS+R7RS |0.7.0     |GitHub Mirror  |                                      |
|[Chicken][]     |R7RS      |4.10.1*   |Official Git   |SKIPTEST, with `r7rs` egg             |
|[Guile][]       |R6RS      |n/a       |Official Git   |TESTFAIL                              |
|[Racket][]      |R6RS      |n/a       |Official GitHub|NOTEST, with `srfi-lib` and `r6rs-lib`|
|[Vicare][]      |R6RS      |n/a       |Official GitHub|TESTFAIL                              |

* Gauche: Uses patched version to build on Cygwin64 host(#5)
* Chicken: Uses development snapshot to bootstrap current official git HEAD


[Stable]: https://bitbucket.org/okuoku/yunibase-impl-stable
[Current]: https://github.com/okuoku/yunibase/tree/master/impl-current
[Docker Hub]: https://hub.docker.com/r/okuoku/yunibase/
[Yuni R6RS/R7RS portability library]: https://github.com/okuoku/yuni
[Linux Docker images]: https://github.com/okuoku/yunibase/tree/master/hosts/docker-linux
[Buildsystem based on Ubuntu LTS]: https://github.com/okuoku/yunibase/blob/master/hosts/docker-linux/base-ubuntuLTS/Dockerfile
[Buildsystem based on Fedora]: https://github.com/okuoku/yunibase/blob/master/hosts/docker-linux/base-fedora/Dockerfile

[Chibi-scheme]: http://synthcode.com/wiki/chibi-scheme
[Gauche]: http://practical-scheme.net/gauche/
[Sagittarius]: https://bitbucket.org/ktakashi/sagittarius-scheme/wiki/Home
[Chicken]: http://www.call-cc.org/
[Guile]: http://www.gnu.org/software/guile/
[Racket]: https://racket-lang.org/
[Vicare]: http://marcomaggi.github.io/vicare.html
