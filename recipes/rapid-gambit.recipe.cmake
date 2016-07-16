set(RECIPE_RAPID_GAMBIT # Recipe for Rapid-Gambit
    STEP "Configure" ${CMAKE_COMMAND} "." 
    "-DRAPID_GAMBIT_USE_CHIBI_SCHEME=ON"
    "-DCMAKE_INSTALL_PREFIX=__INSTALL_PREFIX__"
    # FIXME: Use CMake --build here.
    STEP "Build"     MAKE __MAKE_OPTS__
    STEP "Test"      MAKE test TIMEOUT:600
    STEP "Install"   MAKE install
)
