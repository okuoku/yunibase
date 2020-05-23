set(RECIPE_BIGLOO_STABLE
    STEP "Configure" 
    ./configure --prefix=__INSTALL_PREFIX__
    STEP "Build" 
    MAKE __MAKE_PARALLEL__
    STEP "Install"
    MAKE install
    STEP "Test"
    MAKE test)

set(RECIPE_BIGLOO_CURRENT
    STEP "Configure"
    ./configure --prefix=__INSTALL_PREFIX__
    STEP "Build"
    MAKE bigboot BGLBUILDBINDIR=${YUNIBASE_BUILD_STABLE_PREFIX}/bigloo/bin
    STEP "InstallProgs"
    MAKE install-progs
    STEP "BuildLibraries"
    MAKE fullbootstrap-sans-log
    STEP "Install"
    MAKE install-sans-docs)

