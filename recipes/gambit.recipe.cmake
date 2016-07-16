set(RECIPE_GAMBIT # Recipe for Gambit
    STEP "Configure" "./configure" 
    "--enable-single-host"
    "--prefix=__INSTALL_PREFIX__"
    STEP "Build"     MAKE __MAKE_OPTS__
    STEP "Test"      MAKE check
    STEP "Install"   MAKE install
)

