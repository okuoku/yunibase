set(RECIPE_STKLOS
    STEP "Bootstrap"
    autoreconf -ifv
    STEP "Configure"
    "./configure" "--prefix=__INSTALL_PREFIX__"
    STEP "Build"
    make
    STEP "Install"
    make install)
