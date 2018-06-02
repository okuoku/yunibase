set(RECIPE_S7YUNI # Recipe for s7yuni
    STEP "Configure" ${CMAKE_COMMAND} "-DCMAKE_INSTALL_PREFIX=__INSTALL_PREFIX__" "-DCMAKE_BUILD_TYPE=RelWithDebInfo" "-DS7YUNI_S7_ROOT=${YUNIBASE_ROOT_CURRENT}/snd" "__YUNIROOT__/yunistub/s7yuni"
    # FIXME: Use CMake --build here.
    STEP "Build"     MAKE __MAKE_PARALLEL__ __MAKE_OPTS__
    STEP "Install"   MAKE install
)
