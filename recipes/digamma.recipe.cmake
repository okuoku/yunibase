set(RECIPE_DIGAMMA
    STEP "Build"
    make PREFIX=__INSTALL_PREFIX__ __MAKE_OPTS__
    STEP "Install"
    make install PREFIX=__INSTALL_PREFIX__)
