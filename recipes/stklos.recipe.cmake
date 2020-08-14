set(RECIPE_STKLOS
    STEP "Bootstrap"
    autoreconf -ifv
    STEP "Configure"
    "./configure" "--prefix=__INSTALL_PREFIX__"
    STEP "Build"
    MAKE __MAKE_PARALLEL__
    STEP "Install"
    MAKE install)
