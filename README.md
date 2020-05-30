Yunibase
========

This is Yunibase, collection of R5RS/R6RS/R7RS implementations to test [Yuni Scheme portability platform][].

Prebuilt images
===============

* [Linux Docker image][] on [Docker Hub][]

Implementations
===============

|                  |Code     |Standard  |[Stable][]|[Current][]    |Remarks                               |
|:-----------------|:-------:|:--------:|:--------:|:-------------:|:-------------------------------------|
|[Bigloo][]        |C        |R5RS      |4.3idev   |Official GitHub|Stable patched to install without Java|
|[ChezScheme][]    |C        |R6RS      |          |Official GitHub|                                      |
|[Chibi-scheme][]  |C        |R7RS      |          |Official GitHub|                                      |
|[Chicken][]       |C        |R7RS      |5.1.0rc1  |GitHub Mirror  |With `r7rs` egg                       |
|[Cyclone][]       |C        |R7RS      |(git)     |Official GitHub|                                      |
|[Digamma][]       |C++      |R6RS+R7RS |          |Official GitHub|                                      |
|[Gambit][]        |C        |R5RS+R7RS-|4.9.3devel|Official GitHub|                                      |
|[Gauche][]        |C        |R7RS      |0.9.9     |Official GitHub|                                      |
|[Guile][]         |C        |R6RS+R7RS-|          |Official Git   |                                      |
|[MIT/GNU Scheme][]|C        |R5RS+R7RS-|10.1.1    |Official Git   |amd64 only                            |
|[Racket][]        |C        |R6RS      |          |Official GitHub|With `srfi-lib` and `r6rs-lib`        |
|[s7][]            |C        |Generic   |          |GitHub Mirror  |With yuni patches(s7yuni)             |
|[Sagittarius][]   |C        |R6RS+R7RS |0.9.2     |GitHub Mirror  |                                      |
|[SCM][]           |C        |R5RS      |5f3       |(none)         |Stable only, with SLIB(3b6)           |
|[STklos][]        |C        |R7RS-     |          |Official GitHub|                                      |
|[Kawa][]          |Java     |R7RS      |          |Official Git   |                                      |

* [Stable][] implementations are only included if the implementation requires it to "bootstrap" [Current][] ones



[Stable]: https://bitbucket.org/okuoku/yunibase-impl-stable
[Current]: https://github.com/okuoku/yunibase/tree/master/impl-current
[Yuni Scheme portability platform]: https://github.com/okuoku/yuni
[Linux Docker image]: https://github.com/okuoku/yunibase/tree/master/hosts/docker-linux
[Docker Hub]: https://hub.docker.com/r/okuoku/yunibase/

[ChezScheme]: https://github.com/cisco/ChezScheme
[Chibi-scheme]: http://synthcode.com/wiki/chibi-scheme
[Chicken]: http://www.call-cc.org/
[Cyclone]: http://justinethier.github.io/cyclone/
[Digamma]: https://github.com/fujita-y/digamma
[Gauche]: http://practical-scheme.net/gauche/
[Sagittarius]: https://bitbucket.org/ktakashi/sagittarius-scheme/wiki/Home
[Guile]: https://www.gnu.org/software/guile/
[Racket]: https://racket-lang.org/
[Vicare]: http://marcomaggi.github.io/vicare.html
[Kawa]: http://www.gnu.org/software/kawa/
[Larceny]: http://www.larcenists.org/
[Gambit]: http://gambitscheme.org/
[Rapid-gambit]: https://github.com/okuoku/rapid-gambit
[Picrin]: https://github.com/picrin-scheme/picrin
[MIT/GNU Scheme]: https://www.gnu.org/software/mit-scheme/
[s7]: https://ccrma.stanford.edu/software/snd/snd/s7.html
[STklos]: https://stklos.net/
[SCM]: http://people.csail.mit.edu/jaffer/SCM
[Bigloo]: http://www-sop.inria.fr/indes/fp/Bigloo/
