Build root definitions for Docker (linux)
=========================================

* Build

```
cd IMAGE-DIR
docker build --tag yunibuild-IMAGE .
```

* Use

```
docker run -v /path/to/yunibase:/yunibase -it cmake -P \
  /yunibase/scripts/build-on-root.cmake
```

To build selected implementation,

```
docker run -v /path/to/yunibase:/yunibase -it cmake \
  -DONLY=CHIBI_SCHEME \
  -P /yunibase/scripts/build-on-root.cmake
```

