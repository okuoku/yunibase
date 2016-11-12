set(RECIPE_MIT_SCHEME_C # Recipe for MIT/GNU Scheme (C)
    STEP "Build"     "etc/make-liarc.sh" "--prefix=__INSTALL_PREFIX__"
    STEP "Install"   MAKE install
)

set(RECIPE_MIT_SCHEME_AMD64 # Recipe for MIT/GNU Scheme (C)
    STEP "Configure" "./configure" "--prefix=__INSTALL_PREFIX__"
    STEP "Build"     MAKE __MAKE_PARALLEL__ __MAKE_OPTS__ compile-microcode
    STEP "Install"   MAKE install
)

set(RECIPE_MIT_SCHEME_BOOTSTRAP   # Recipe for MIT/GNU Scheme
    STEP "Bootstrap" "./Setup.sh"
    STEP "Configure" "./configure" "--prefix=__INSTALL_PREFIX__"
    #    STEP "Test"      MAKE test
    STEP "Build"     MAKE __MAKE_PARALLEL__ __MAKE_OPTS__
    STEP "Install"   MAKE install
)

