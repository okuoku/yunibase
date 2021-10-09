set(RECIPE_STKLOS
    STEP "Bootstrap"
    ./utils/time-correct
    STEP "Configure"
    "./configure" "--prefix=__INSTALL_PREFIX__"
    STEP "Build"
    MAKE 
    STEP "Install"
    MAKE install)
