set(xxxxx-missing
    # CHICKEN # Replaced with CHICKEN5
    # GUILE # Replaced with GUILE3
    # NMOSH # Dormant
    # PICRIN # Dormant
    # VICARE # Dormant
    )

set(ubuntu64-impls
    BIGLOO
    CHEZ
    CHIBI_SCHEME
    CHICKEN5
    CYCLONE
    DIGAMMA
    FOMENT
    GAMBIT
    GAUCHE
    GUILE3
    # IRON_SCHEME # Buildsystem is Windows only
    KAWA
    MIT_SCHEME
    RACKET
    S7YUNI
    # SAGITTARIUS # Tentative
    SCM
    STKLOS
    # MOSH # Docker build do not support cross-impl bootstrap
    )

set(ubuntu64single-impls
    GAUCHE
    MOSH
    )

set(win64vs-impls # VS2019(YUNIBASE_USE_VS) + CMake
    CHIBI_SCHEME
    FOMENT
    IRON_SCHEME
    SAGITTARIUS
    # RACKET # ??
    )
set(win64make-impls # Use Cygwin buildsystem + VisualStudio compiler
    CHEZ
    )
set(win64mingw-impls # MinGW + GCC
    GAUCHE
    CHICKEN5
    GAMBIT
    # GUILE3 # ??
    )

set(cygwin64-impls
    # BIGLOO # Current build fail
    # CHEZ # Not supported
    CHIBI_SCHEME
    CHICKEN5
    # CYCLONE # Cygwin does not have Concurrency Kit package
    # DIGAMMA # Not supported ??
    # FOMENT # Depends on <execinfo.h> backtrace(3)
    # GAMBIT # RENAME_NOREPLACE misplaced in Cygwin
    GAUCHE
    #GUILE3 # Broken on Cygwin64
    # IRON_SCHEME # Buildsystem is Windows only
    # KAWA # Prefer Linux build
    # MIT_SCHEME # Not supported ??
    # RACKET # Not supported ??
    S7YUNI
    # SAGITTARIUS # Crashes on Cygwin64
    # SCM # ??
    # STKLOS # Cygwin support broken on Win64 (Cygwin 1.7 or later)
    MOSH
    )

set(macosintel-impls
    # BIGLOO # Depends "glibtoolize"
    CHEZ
    CHIBI_SCHEME
    # CHICKEN5 # Need Xcode path support https://github.com/okuoku/yunibase/issues/109
    # CYCLONE # Link error
    # DIGAMMA # ??
    # FOMENT # https://github.com/leftmike/foment/pull/39
    GAMBIT
    GAUCHE
    # GUILE3 # https://github.com/okuoku/yunibase/issues/94
    # IRON_SCHEME # Buildsystem is Windows only
    # KAWA # Prefer Linux build
    # MIT_SCHEME # Cannot support (threaded) W^X
    RACKET
    S7YUNI
    # SAGITTARIUS # pkgsrc OpenSSL is not compatible
    # SCM # It's stable only for now
    STKLOS
    MOSH
    )

set(freebsd-impls
    # BIGLOO
    # CHEZ # Not supported
    CHIBI_SCHEME
    CHICKEN5
    # CYCLONE # Needs concurrency kit
    # DIGAMMA # ??
    # FOMENT # Require C++2a
    # GAMBIT # Lacks -lm
    GAUCHE
    # GUILE3 # Requires GNU m4 to bootstrap
    # IRON_SCHEME # Buildsystem is Windows only
    # KAWA # Prefer Linux build
    # MIT_SCHEME # Unknown failure
    RACKET
    # S7YUNI # Needs to be ported
    # SAGITTARIUS # GC compatibility
    # SCM # It's stable only for now
    # STKLOS # GC compatibility
    MOSH
    )

set(dragonfly-impls
    # BIGLOO
    # CHEZ # Not supported
    CHIBI_SCHEME # Infinite ldconfig(Workarounded)
    # CHICKEN5 # POSIX incompatibility
    # CYCLONE # Needs concurrency kit
    # DIGAMMA # ??
    # FOMENT # Require C++2a
    # GAMBIT # Lacks -lm
    GAUCHE
    # GUILE3 # Requires GNU m4 to bootstrap
    # IRON_SCHEME # Buildsystem is Windows only
    # KAWA # Prefer Linux build
    # MIT_SCHEME # Unknown failure
    # RACKET # Platform is not supported by Racket CS. Try --enable-bcdefault
    # S7YUNI # Needs to be ported
    # SAGITTARIUS # GC compatibility
    # SCM # It's stable only for now
    # STKLOS # GC compatibility
    MOSH
    )

set(netbsd-impls
    # BIGLOO
    # CHEZ # Not supported
    CHIBI_SCHEME
    CHICKEN5
    # CYCLONE # Needs concurrency kit
    # DIGAMMA # ??
    # FOMENT # Require C++2a
    # GAMBIT # Not supported
    GAUCHE
    # GUILE3 # Requires GNU m4 to bootstrap
    # IRON_SCHEME # Buildsystem is Windows only
    # KAWA # Prefer Linux build
    # MIT_SCHEME # Unknown failure
    # RACKET # Incompatible with make -j?
    # S7YUNI # Needs to be ported
    # SAGITTARIUS # OpenSSL compatibility
    # SCM # It's stable only for now
    STKLOS
    MOSH
    )

set(openbsd-impls
    # BIGLOO
    # CHEZ # Not supported
    CHIBI_SCHEME
    CHICKEN5
    # CYCLONE # Needs concurrency kit
    # DIGAMMA # ??
    # FOMENT # Not supported
    # GAMBIT # out-of-memory during compilation
    GAUCHE
    # GUILE3 # Requires GNU m4 to bootstrap
    # IRON_SCHEME # Buildsystem is Windows only
    # KAWA # Prefer Linux build
    # MIT_SCHEME # Unknown failure
    RACKET
    # S7YUNI # Needs to be ported
    # SAGITTARIUS # OpenSSL compatibility
    # SCM # It's stable only for now
    STKLOS
    MOSH
    )

