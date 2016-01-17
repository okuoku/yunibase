Yunibase
========

This is Yunibase, collection of R6RS/R7RS implementations to test [Yuni R6RS/R7RS portability library][].

Supported build environments
============================

 * [Linux Docker images][]
  * `okuoku/yunibuild:latest` - [Buildsystem based on Ubuntu LTS][]
  * `okuoku/yunibuild:latest-fedora` - [Buildsystem based on Fedora][]

Implementations
===============

 * R7RS (Including R6RS hybrid)
  * chibi-scheme
  * Gauche (0.9.4 for bootstrap)
  * NMosh (No bootstrap support for now)
  * Sagittarius (0.6.11 for bootstrap)
  * Chicken (Disabled, 4.10.0 for bootstrap, with r7rs egg)
  
* R6RS
  * Guile (Disabled)
  * Racket (with srfi-lib and r6rs-lib)
  * Vicare


[Yuni R6RS/R7RS portability library]: https://github.com/okuoku/yuni
[Linux Docker images]: https://github.com/okuoku/yunibase/tree/master/hosts/docker-linux
[Buildsystem based on Ubuntu LTS]: https://github.com/okuoku/yunibase/blob/master/hosts/docker-linux/base-ubuntuLTS/Dockerfile
[Buildsystem based on Fedora]: https://github.com/okuoku/yunibase/blob/master/hosts/docker-linux/base-fedora/Dockerfile
