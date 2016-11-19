set(RECIPE_GAMBIT # Recipe for Gambit
    STEP "Configure" "./configure" 
    "--enable-single-host"
    "--prefix=__INSTALL_PREFIX__"
    STEP "Build"     MAKE __MAKE_PARALLEL__ __MAKE_OPTS__
    STEP "Test"      MAKE check
    STEP "Install"   MAKE install
)

set(RECIPE_GAMBIT_BOOTSTRAP
    STEP "SetupGscBoot" cp ${YUNIBASE_BUILD_STABLE_PREFIX}/gambit/bin/gsc
    gsc-boot
    STEP "ConfigureFirst" "./configure" "--enable-single-host"
    STEP "Bootstrap1" MAKE bootclean
    STEP "Bootstrap2" MAKE bootstrap
    STEP "Bootstrap3" MAKE bootclean
    ${RECIPE_GAMBIT})
