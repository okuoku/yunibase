set(RECIPE_CHEZ # Recipe for Chez Scheme
    STEP "Configure" "./configure" "--installprefix=__INSTALL_PREFIX__" 
    "--installman=__INSTALL_PREFIX__/share/man"
    "--threads"
    STEP "Build"     MAKE __MAKE_OPTS__
    #    STEP "Test"      MAKE test
    STEP "Install"   MAKE install
)

