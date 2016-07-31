set(RECIPE_GUILE # Recipe for Guile
    STEP "Bootstrap" "./autogen.sh"
    STEP "Configure" "./configure" "--prefix=__INSTALL_PREFIX__"
    STEP "Build"     MAKE __MAKE_OPTS__
    # STEP "Test"      MAKE check
    STEP "Install"   MAKE install
)
