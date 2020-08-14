set(RECIPE_RACKET_MACOS
    STEP "Build" make # Use system default make
    unix-style 
    PREFIX=__INSTALL_PREFIX__ 
    "\"PKGS=r6rs-lib srfi-lib\""
    )

set(RECIPE_RACKET_CURRENT # We do not support in-tree tests yet
    STEP "Configure" "./configure" "--prefix=__INSTALL_PREFIX__"
    --enable-racket=racket
    STEP "Build" MAKE __MAKE_OPTS__ __MAKE_PARALLEL__
    STEP "Install" MAKE __MAKE_PARALLEL__ install
    )

set(RECIPE_RACKET_STABLE # We do not support in-tree tests yet
    STEP "Configure" "./configure" "--prefix=__INSTALL_PREFIX__"
    STEP "Build" MAKE __MAKE_OPTS__ __MAKE_PARALLEL__
    STEP "Install" MAKE __MAKE_PARALLEL__ install
    )

set(RECIPE_RACKET_SETUP
    STEP "SetupRacketLib" raco pkg install --skip-installed --copy
    --scope installation --batch -j __MAKE_JOBS__
    ${YUNIBASE_ROOT_CURRENT}/racket/pkgs/racket-lib

    STEP "SetupBase" raco pkg install --skip-installed --copy
    --scope installation --batch -j __MAKE_JOBS__
    ${YUNIBASE_ROOT_CURRENT}/racket/pkgs/base

    STEP "SetupSRFILite" raco pkg install --skip-installed --copy
    --scope installation --batch -j __MAKE_JOBS__
    ${YUNIBASE_ROOT_CURRENT}/racket-pkgs/srfi/srfi-lite-lib

    STEP "SetupNetLib" raco pkg install --skip-installed --copy
    --scope installation --batch -j __MAKE_JOBS__
    ${YUNIBASE_ROOT_CURRENT}/racket/pkgs/net-lib

    STEP "SetupSchemeLib" raco pkg install --skip-installed --copy
    --scope installation --batch -j __MAKE_JOBS__
    ${YUNIBASE_ROOT_CURRENT}/racket-pkgs/scheme-lib

    STEP "SetupSourceSyntax" raco pkg install --skip-installed --copy
    --scope installation --batch -j __MAKE_JOBS__
    ${YUNIBASE_ROOT_CURRENT}/racket-pkgs/typed-racket/source-syntax
    
    STEP "SetupErrortraceLib" raco pkg install --skip-installed --copy
    --scope installation --batch -j __MAKE_JOBS__
    ${YUNIBASE_ROOT_CURRENT}/racket-pkgs/errortrace/errortrace-lib
    
    STEP "SetupSandboxLib" raco pkg install --skip-installed --copy
    --scope installation --batch -j __MAKE_JOBS__
    ${YUNIBASE_ROOT_CURRENT}/racket-pkgs/sandbox-lib

    STEP "SetupCompatibilityLib" raco pkg install --skip-installed --copy
    --scope installation --batch -j __MAKE_JOBS__
    ${YUNIBASE_ROOT_CURRENT}/racket-pkgs/compatibility/compatibility-lib

    STEP "SetupR5RS" raco pkg install --skip-installed --copy
    --scope installation --batch -j __MAKE_JOBS__
    ${YUNIBASE_ROOT_CURRENT}/racket-pkgs/r5rs/r5rs-lib

    STEP "SetupR6RS" raco pkg install --skip-installed --copy
    --scope installation --batch -j __MAKE_JOBS__
    ${YUNIBASE_ROOT_CURRENT}/racket-pkgs/r6rs/r6rs-lib

    STEP "SetupSRFI" raco pkg install --skip-installed --copy
    --scope installation --batch -j __MAKE_JOBS__
    ${YUNIBASE_ROOT_CURRENT}/racket-pkgs/srfi/srfi-lib
    )

