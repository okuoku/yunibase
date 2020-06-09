set(RECIPE_CYCLONE
    STEP "Build" 
    MAKE "PREFIX=__INSTALL_PREFIX__" __AUTOCONF_OPTS__
    STEP "Install"
    MAKE "PREFIX=__INSTALL_PREFIX__" install
    STEP "Test"
    MAKE test)
