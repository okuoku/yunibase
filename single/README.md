Single-pass build
=================

Yunibase single-pass build generates Scheme distributions for several OSes,
in single-pass.

## Additional dependencies

- rsync -- to copy source tree into build location
- CMake
- Ninja

For BSD OSes, `gmake` is also required to build Schemes correctly.

## Linux (Ubuntu AMD64)

## FreeBSD AMD64

Required packages:

```
gmake autoconf automake gmp oniguruma libtool 
libunistring libffi texinfo boehm-gc-threaded rsync cmake ninja ncurses
```

Installed from ports collection with `pkg install`.


## NetBSD AMD64

Required packages:


```
gmake autoconf automake gmp oniguruma libtool libunistring 
libffi texinfo boehm-gc rsync cmake ninja-build ncurses
```

Installed from pkgsrc with `pkgin install`.

## OpenBSD AMD64

Required packages:

```
gmake autoconf automake gmp oniguruma libtool libunistring 
  libffi texinfo boehm-gc rsync cmake ninja
```

Installed from ports collection with `pkg_add`.

## DragonFly BSD AMD64

Required packages:

```
gmake autoconf automake gmp oniguruma libtool 
libunistring libffi texinfo boehm-gc-threaded rsync cmake ninja ncurses
```

Installed from ports collection with `pkg install`.

