set(RECIPE_SAGITTARIUS # Receipe for Sagittarius
    # FIXME: Say "Unix Makefiles" here.
    STEP "Configure" ${CMAKE_COMMAND} "." "-DCMAKE_INSTALL_PREFIX=__INSTALL_PREFIX__"
    STEP "Build"     MAKE __MAKE_OPTS__
    STEP "Test"      MAKE test
    STEP "Install"   MAKE install
)

set(BOOTSTRAP_SAGITTARIUS # Bootstrap for Sagittarius
    STEP "Bootstrap" "./dist.sh" gen
)

list(APPEND BOOTSTRAP_SAGITTARIUS ${RECIPE_SAGITTARIUS})
