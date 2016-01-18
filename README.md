Yunibase
========

This is Yunibase, collection of R6RS/R7RS implementations to test [Yuni R6RS/R7RS portability library][].

Prebuilt images
===============

* [Linux Docker images][] on [Docker Hub][]
 * `okuoku/yunibase:testing` - Ubuntu LTS
 * `okuoku/yunibase:testing-fedora` - Fedora latest

Supported build environments
============================

 * [Linux Docker images][]
  * `okuoku/yunibuild:latest` - [Buildsystem based on Ubuntu LTS][]
  * `okuoku/yunibuild:latest-fedora` - [Buildsystem based on Fedora][]

Implementations
===============

## R7RS and R6RS Hybrid

|            |[Stable][]|[Current][]    |Remarks                  |
|:-----------|:--------:|:-------------:|:------------------------|
|Chibi-scheme|n/a       |Official GitHub|                         |
|Gauche      |0.9.4     |Official GitHub|                         |
|NMosh       |current   |not yet        |TESTFAIL                 |
|Sagittarius |0.6.11    |GitHub Mirror  |                         |
|Chicken     |4.10.0    |Official Git   |SKIPTEST, with `r7rs` egg|

## R6RS

|      |[Stable][]|[Current][]    |Remarks                               |
|:-----|:--------:|:-------------:|:-------------------------------------|
|Guile |n/a       |Official Git   |TESTFAIL                              |
|Racket|n/a       |Official GitHub|NOTEST, with `srfi-lib` and `r6rs-lib`|
|Vicare|n/a       |Official GitHub|TESTFAIL                              |



[Stable]: https://bitbucket.org/okuoku/yunibase-impl-stable
[Current]: https://github.com/okuoku/yunibase/tree/master/impl-current
[Docker Hub]: https://hub.docker.com/r/okuoku/yunibase/
[Yuni R6RS/R7RS portability library]: https://github.com/okuoku/yuni
[Linux Docker images]: https://github.com/okuoku/yunibase/tree/master/hosts/docker-linux
[Buildsystem based on Ubuntu LTS]: https://github.com/okuoku/yunibase/blob/master/hosts/docker-linux/base-ubuntuLTS/Dockerfile
[Buildsystem based on Fedora]: https://github.com/okuoku/yunibase/blob/master/hosts/docker-linux/base-fedora/Dockerfile
