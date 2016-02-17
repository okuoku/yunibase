Yunibase
========

[![wercker status](https://app.wercker.com/status/0c36dd5ef969e9f4d3ff7e5ca759faba/m "wercker status")](https://app.wercker.com/project/bykey/0c36dd5ef969e9f4d3ff7e5ca759faba)

This is Yunibase, collection of R6RS/R7RS implementations to test [Yuni R6RS/R7RS portability library][].

Build environments
==================

* Windows
 * Cygwin64
* Vagrant
 * [Official FreeBSD Vagrant images][] on Atlas
  * `freebsd/FreeBSD-10.2-STABLE`, `freebsd/FreeBSD-11.0-CURRENT`
* [Linux Docker images][] on [Docker hub][]
 * UbuntuLTS, Fedora, Alpine and official JDK8

Prebuilt images
===============

* [Linux Docker images][] on [Docker Hub][]
 * `okuoku/yunibase:testing` [![](https://badge.imagelayers.io/okuoku/yunibase:testing.svg)](https://imagelayers.io/?images=okuoku/yunibase:testing) - Ubuntu LTS
 * `okuoku/yunibase:testing-fedora` [![](https://badge.imagelayers.io/okuoku/yunibase:testing-fedora.svg)](https://imagelayers.io/?images=okuoku/yunibase:testing-fedora) - Fedora latest
 * `okuoku/yunibase:testing-alpine` [![](https://badge.imagelayers.io/okuoku/yunibase:testing-alpine.svg)](https://imagelayers.io/?images=okuoku/yunibase:testing-alpine) - Alpine Edge(Not used in Yuni for now)
 * `okuoku/yunibase:testing-java` [![](https://badge.imagelayers.io/okuoku/yunibase:testing-java.svg)](https://imagelayers.io/?images=okuoku/yunibase:testing-java) - Java (JDK 8 from Docker official image)

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
|[Kawa][]        |R7RS      |n/a       |GitHub Mirror  |SKIPTEST                              |

* Gauche: Uses patched version to build on Cygwin64 host(#5)
* Chicken: Uses development snapshot to bootstrap current official git HEAD

Platform matrix
===============

Linux
-----
|                |UbuntuLTS|Fedora|Alpine|Java |Remarks|
|:---------------|:-------:|:----:|:----:|:---:|:------|
|(Foundation)    |glibc    |glibc |Musl  |Java8|       |
|[Chibi-scheme][]|X        |X     |X     |     |       |
|[Gauche][]      |X        |X     |      |     |       |
|NMosh           |X        |X     |      |     |Also included in Java image to bootstrap Yuni|
|[Sagittarius][] |X        |      |      |     |       |
|[Chicken][]     |X        |X     |X     |     |       |
|[Guile][]       |X        |      |      |     |Not enabled except UbuntuLTS due to excessive build time|
|[Racket][]      |X        |X     |      |     |       |
|[Vicare][]      |X        |X     |      |     |       |
|[Kawa][]        |         |      |      |X    |       |

Windows
-------
|                |Cygwin64|Remarks|
|:---------------|:------:|:------|
|(Foundation)    |newlib  |       |
|[Chibi-scheme][]|X       |       |
|[Gauche][]      |X       |       |
|NMosh           |X       |       |
|[Sagittarius][] |X       |       |
|[Chicken][]     |X       |       |
|[Guile][]       |        |       |
|[Racket][]      |        |       |
|[Vicare][]      |        |       |

Others
------
|                |FBSD10 |FBSD11 |Remarks|
|:---------------|:-----:|:-----:|:------|
|(Foundation)    |freebsd|freebsd|       |
|[Chibi-scheme][]|X      |X      |       |
|[Gauche][]      |       |       |       |
|NMosh           |X      |X      |       |
|[Sagittarius][] |       |       |       |
|[Chicken][]     |       |       |       |
|[Guile][]       |       |       |       |
|[Racket][]      |X      |X      |       |
|[Vicare][]      |       |       |       |


[Stable]: https://bitbucket.org/okuoku/yunibase-impl-stable
[Current]: https://github.com/okuoku/yunibase/tree/master/impl-current
[Docker Hub]: https://hub.docker.com/r/okuoku/yunibase/
[Yuni R6RS/R7RS portability library]: https://github.com/okuoku/yuni
[Linux Docker images]: https://github.com/okuoku/yunibase/tree/master/hosts/docker-linux
[Official FreeBSD Vagrant images]: https://atlas.hashicorp.com/FreeBSD/

[Chibi-scheme]: http://synthcode.com/wiki/chibi-scheme
[Gauche]: http://practical-scheme.net/gauche/
[Sagittarius]: https://bitbucket.org/ktakashi/sagittarius-scheme/wiki/Home
[Chicken]: http://www.call-cc.org/
[Guile]: http://www.gnu.org/software/guile/
[Racket]: https://racket-lang.org/
[Vicare]: http://marcomaggi.github.io/vicare.html
[Kawa]: http://www.gnu.org/software/kawa/
