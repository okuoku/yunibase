Buildsystem definitions for Docker (linux)
==========================================

* Build

```
cd IMAGE-DIR
docker build --tag yunibuild-TYPE .
```

* Use

```
docker run --rm -v /path/to/yunibase:/yunibase -it yunibuild-TYPE \
  cmake -P /yunibase/scripts/build-on-root.cmake
```

To build selected implementation,

```
docker run --rm -v /path/to/yunibase:/yunibase -it yunibuild-TYPE \
  cmake -DONLY=CHIBI_SCHEME \
  -P /yunibase/scripts/build-on-root.cmake
```

