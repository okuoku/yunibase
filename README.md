Yunibase
========

[![wercker status](https://app.wercker.com/status/0c36dd5ef969e9f4d3ff7e5ca759faba/m "wercker status")](https://app.wercker.com/project/bykey/0c36dd5ef969e9f4d3ff7e5ca759faba)

This is Yunibase, collection of R6RS/R7RS implementations to test [Yuni R6RS/R7RS portability library][].

Build environments
==================

* Windows
 * Cygwin64
* Vagrant
 * [Official FreeBSD Vagrant images][] on Atlas - `freebsd/FreeBSD-10.2-STABLE` and `freebsd/FreeBSD-11.0-CURRENT` 
 * Docker image build on `fedora/23-cloud-base`
* [Linux Docker images][] on Docker hub
 * UbuntuLTS, Fedora, Alpine, official JDK8 and unofficial `32bit/ubuntu`

Prebuilt images
===============

* [Linux Docker images][] on [Docker Hub][]
 * `okuoku/yunibase:testing` [![](https://badge.imagelayers.io/okuoku/yunibase:testing.svg)](https://imagelayers.io/?images=okuoku/yunibase:testing) - Ubuntu LTS
 * `okuoku/yunibase:testing-fedora` [![](https://badge.imagelayers.io/okuoku/yunibase:testing-fedora.svg)](https://imagelayers.io/?images=okuoku/yunibase:testing-fedora) - Fedora latest
 * `okuoku/yunibase:testing-alpine` [![](https://badge.imagelayers.io/okuoku/yunibase:testing-alpine.svg)](https://imagelayers.io/?images=okuoku/yunibase:testing-alpine) - Alpine Edge(Not used in Yuni for now)
 * `okuoku/yunibase:testing-java` [![](https://badge.imagelayers.io/okuoku/yunibase:testing-java.svg)](https://imagelayers.io/?images=okuoku/yunibase:testing-java) - Java (JDK 8 from Docker official image)
 * `okuoku/yunibase:testing-ubuntu32` [![](https://badge.imagelayers.io/okuoku/yunibase:testing-ubuntu32.svg)](https://imagelayers.io/?images=okuoku/yunibase:testing-ubuntu32) - Ubuntu i686 LTS (from unofficial `32bit/ubuntu`)

Implementations
===============

|                |Code     |Standard  |[Stable][]|[Current][]    |Remarks                               |
|:---------------|:-------:|:--------:|:--------:|:-------------:|:-------------------------------------|
|[Chibi-scheme][]|C        |R7RS      |          |Official GitHub|                                      |
|[Gauche][]      |C        |R7RS      |0.9.4+    |Official GitHub|                                      |
|NMosh           |C++      |R6RS+R7RS-|current   |not yet        |                                      |
|[Sagittarius][] |C        |R6RS+R7RS |0.7.1     |GitHub Mirror  |                                      |
|[Chicken][]     |C        |R7RS      |4.10.1*   |Official Git   |SKIPTEST, with `r7rs` egg             |
|[Guile][]       |C        |R6RS      |          |Official Git   |                                      |
|[Racket][]      |C        |R6RS      |          |Official GitHub|NOTEST, with `srfi-lib` and `r6rs-lib`|
|[Vicare][]      |C        |R6RS      |          |Official GitHub|                                      |
|[Larceny][]     |Scheme, C|R6RS+R7RS |0.98*     |Official GitHub|NOTEST                                |
|[Kawa][]        |Java     |R7RS      |          |GitHub Mirror  |NOTEST                                |

* [Stable][] implementations are only included if the implementation requires it to "bootstrap" [Current][] ones
* NOTEST: Yunibase does not support testing on this implementation
* SKIPTEST: Yunibase always skips test on this implementation
* Gauche: Uses patched version to build on Cygwin64 host(#5)
* Chicken: Uses development snapshot to bootstrap current official git HEAD
* Larceny: Uses binary distribution for Stable build

Platform matrix
===============

Linux(amd64)
------------
|                |UbuntuLTS|Fedora|Alpine|Java |Ubuntu32*|Remarks|
|:---------------|:-------:|:----:|:----:|:---:|:-------:|:------|
|(Foundation)    |glibc    |glibc |Musl  |Java8|glibc    |       |
|[Chibi-scheme][]|X        |X     |X     |     |X        |       |
|[Gauche][]      |X        |X     |      |     |X        |       |
|NMosh           |X        |X     |      |     |X        |Also included in Java image to bootstrap Yuni|
|[Sagittarius][] |X        |      |      |     |X        |       |
|[Chicken][]     |X        |X     |X     |     |X        |       |
|[Guile][]       |X        |      |      |     |         |Not enabled except UbuntuLTS due to excessive build time|
|[Racket][]      |X        |X     |      |     |X        |       |
|[Vicare][]      |X        |X     |      |     |         |       |
|[Larceny][]     |         |      |      |     |X        |       |
|[Kawa][]        |         |      |      |X    |         |       |

* Ubuntu32: Run on amd64 kernel, using patched `uname` command to fake architecture as i686.

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
[Larceny]: http://www.larcenists.org/
