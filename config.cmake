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
