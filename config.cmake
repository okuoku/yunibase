set(ubuntu64-impls
    BIGLOO
    CHEZ
    CHIBI_SCHEME
    # CHICKEN # Replaced with CHICKEN5
    CHICKEN5
    CYCLONE
    DIGAMMA
    FOMENT
    GAMBIT
    GAUCHE
    # GUILE # Replaced with GUILE3
    GUILE3
    # IRON_SCHEME # Buildsystem is Windows only
    KAWA
    # MIT_SCHEME # Waiting 10.1.11
    # NMOSH # Dormant
    # PICRIN # Dormant
    RACKET
    S7YUNI
    SAGITTARIUS
    SCM
    STKLOS
    # VICARE # Dormant
    )

set(win64vs-impls # VS2019(YUNIBASE_USE_VS) + CMake
    CHIBI_SCHEME
    FOMENT
    IRON_SCHEME
    SAGITTARIUS
    )
set(win64make-impls # Use Cygwin buildsystem + VisualStudio compiler
    CHEZ
    )
set(win64mingw-impls # MinGW + GCC
    GAUCHE
    CHICKEN5
    GAMBIT
    )


set(cygwin64-impls
    GUILE3
    GAUCHE
    CHIBI_SCHEME
    CHICKEN5
    S7YUNI
    SAGITTARIUS

    # CYCLONE # Cygwin does not have Concurrency Kit package
    # STKLOS # Cygwin support broken on Win64 (Cygwin 1.7 or later)
    # BIGLOO # Current build fail
    # GAMBIT # RENAME_NOREPLACE misplaced in Cygwin
    # FOMENT # Depends on <execinfo.h> backtrace(3)
    )

set(macos-impls
    GAUCHE
    CHIBI_SCHEME
    CHICKEN5
    STKLOS
    GAMBIT
    FOMENT

    # SAGITTARIUS
    # CYCLONE
    # GUILE3
    )
