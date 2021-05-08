if(CYGWIN)
    execute_process(
        COMMAND cygpath -m -d /
        OUTPUT_VARIABLE BIGLOO_CYGWINDOSPATH_OUT
        )
    set(BIGLOO_CYGWINDOSPATH
        --cygwin-dos-path=${BIGLOO_CYGWINDOSPATH_OUT}
        --cygwin-dos-jvm=no)
else()
    set(BIGLOO_CYGWINDOSPATH)
endif()

set(RECIPE_BIGLOO_STABLE
    STEP "Configure" 
    ./configure --prefix=__INSTALL_PREFIX__ ${BIGLOO_CYGWINDOSPATH}
    STEP "Build" 
    MAKE __MAKE_PARALLEL__
    STEP "Install"
    MAKE install
    STEP "Test"
    MAKE test)

set(RECIPE_BIGLOO_CURRENT
    STEP "Configure"
    ./configure --prefix=__INSTALL_PREFIX__ ${BIGLOO_CYGWINDOSPATH}
    STEP "Build"
    MAKE hostboot BGLBUILDBINDIR=${YUNIBASE_BUILD_STABLE_PREFIX}/bigloo/bin
    STEP "InstallProgs"
    MAKE install-progs
    STEP "BuildLibraries"
    MAKE fullbootstrap-sans-log
    STEP "Install"
    MAKE install-sans-docs)

