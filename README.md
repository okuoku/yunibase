Yunibase
========

[![wercker status](https://app.wercker.com/status/0c36dd5ef969e9f4d3ff7e5ca759faba/m "wercker status")](https://app.wercker.com/project/bykey/0c36dd5ef969e9f4d3ff7e5ca759faba)

This is Yunibase, collection of R5RS/R6RS/R7RS implementations to test [Yuni R6RS/R7RS portability library][].

Build environments
==================

* Windows
 * Cygwin64
* Vagrant
 * [Official FreeBSD Vagrant images][] on Atlas - `freebsd/FreeBSD-10.3-RELEASE` and `freebsd/FreeBSD-11.0-CURRENT` 
 * Docker image build on `fedora/24-cloud-base`
* [Linux Docker images][] on Docker hub
 * UbuntuLTS, Fedora, Alpine, official JDK8 and unofficial `i386/ubuntu`
* macOS with pkgsrc

Prebuilt images
===============

[![](https://images.microbadger.com/badges/image/okuoku/yunibase.svg)](http://microbadger.com/images/okuoku/yunibase "Get your own image badge on microbadger.com")

* [Linux Docker images][] on [Docker Hub][]
 * `okuoku/yunibase:latest` - Ubuntu LTS (16.04)
 * `okuoku/yunibase:yuni-fedora` - Fedora latest
 * `okuoku/yunibase:yuni-alpine` - Alpine Edge
 * `okuoku/yunibase:yuni-java` - Java (JDK 8 from Docker official image)
 * `okuoku/yunibase:yuni-ubuntu32` - Ubuntu i686 LTS (16.04 from unofficial `i386/ubuntu`)

Implementations
===============

|                  |Code     |Standard  |[Stable][]|[Current][]    |Remarks                               |
|:-----------------|:-------:|:--------:|:--------:|:-------------:|:-------------------------------------|
|[Chibi-scheme][]  |C        |R7RS      |          |Official GitHub|                                      |
|[Chicken][]       |C        |R7RS      |4.11.0    |Official Git   |With `r7rs` egg                       |
|[Gauche][]        |C        |R7RS      |0.9.5     |Official GitHub| |
|[Sagittarius][]   |C        |R6RS+R7RS |0.7.9     |GitHub Mirror  |                                      |
|NMosh             |C++      |R6RS+R7RS-|current   |not yet        |                                      |
|[ChezScheme][]    |C        |R6RS      |          |Official GitHub|                                      |
|[Guile][]         |C        |R6RS      |          |Official Git   |                                      |
|[Racket][]        |C        |R6RS      |          |Official GitHub|With `srfi-lib` and `r6rs-lib`        |
|[Vicare][]        |C        |R6RS      |          |Official GitHub|                                      |
|[Larceny][]       |C        |R6RS+R7RS |0.99      |Official GitHub|Stable: Uses binary                   |
|[Picrin][]        |C        |R7RS      |          |Official GitHub|With yuniffi patches                  |
|[Gambit][]        |C        |R5RS      |4.8.5     |Official GitHub|                                      |
|[MIT/GNU Scheme][]|C        |R5RS      |9.2       |Official Git   |amd64 only                            |
|[Kawa][]          |Java     |R7RS      |          |GitHub Mirror  |                                      |

* [Stable][] implementations are only included if the implementation requires it to "bootstrap" [Current][] ones

Platform matrix
===============

Linux(amd64)
------------
|                  |UbuntuLTS|Fedora|Alpine|Ubuntu32|Remarks|
|:-----------------|:-------:|:----:|:----:|:------:|:------|
|(Foundation)      |glibc    |glibc |Musl  |glibc   |       |
|[Chibi-scheme][]  |X        |X     |X     |X       |       |
|[Chicken][]       |X        |X     |X     |X       |       |
|[Gauche][]        |X        |X     |      |        |       |
|[Sagittarius][]   |X        |X     |      |        |       |
|NMosh             |X        |X     |      |        |       |
|[ChezScheme][]    |X        |X     |      |X       |       |
|[Guile][]         |X        |      |      |        |Not enabled except UbuntuLTS due to excessive build time|
|[Racket][]        |X        |X     |      |X       |       |
|[Vicare][]        |X        |X     |      |        |       |
|[Larceny][]       |         |      |      |X       |       |
|[Picrin][]        |X        |X     |X     |X       |       |
|[Gambit][]        |X        |X     |      |X       |       |
|[MIT/GNU Scheme][]|X        |X     |      |        |       |

* Ubuntu32: Run on amd64 kernel, using patched `uname` command to fake architecture as i686.
* Ubuntu32: Disabled BoehmGC based implementations #25

Windows
-------
|                  |Cygwin64|WSL      |Remarks|
|:-----------------|:------:|:-------:|:------|
|(KernelABI)       |nt      |Linux 3.4|       |
|(Foundation)      |newlib  |glibc    |       |
|[Chibi-scheme][]  |X       |X        |       |
|[Chicken][]       |X       |X        |       |
|[Gauche][]        |X       |X        |SKIPTEST on WSL       |
|[Sagittarius][]   |X       |X        |SKIPTEST on WSL       |
|NMosh             |X       |         |TESTFAIL       |
|[ChezScheme][]    |        |X        |       |
|[Guile][]         |        |X        |       |
|[Racket][]        |        |         |       |
|[Vicare][]        |        |         |       |
|[Picrin][]        |        |X        |       |
|[Gambit][]        |        |X        |TESTFAIL on WSL       |
|[MIT/GNU Scheme][]|        |X        |       |

* WSL: Windows Subsystem for Linux aka. "Bash on Windows"

Others
------
|                |macOS     |FBSD10 |FBSD11 |Remarks|
|:---------------|:--------:|:-----:|:-----:|:------|
|(Foundation)    |osx       |freebsd|freebsd|       |
|[Chibi-scheme][]|X         |X      |X      |       |
|[Chicken][]     |X         |X      |       |       |
|[Gauche][]      |X         |       |       |       |
|[Sagittarius][] |X         |       |       |       |
|NMosh           |X         |X      |X      |       |
|[ChezScheme][]  |X         |       |       |       |
|[Guile][]       |X         |       |       |       |
|[Racket][]      |X         |X      |X      |       |
|[Vicare][]      |          |       |       |       |
|[Picrin][]      |X         |       |       |       |
|[Gambit][]      |          |       |       |       |

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
[ChezScheme]: https://github.com/cisco/ChezScheme
[Gambit]: http://gambitscheme.org/
[Rapid-gambit]: https://github.com/okuoku/rapid-gambit
[Picrin]: https://github.com/picrin-scheme/picrin
[MIT/GNU Scheme]: https://www.gnu.org/software/mit-scheme/
