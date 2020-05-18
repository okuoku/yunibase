# Recipe for Foment
# There is no bootstrap phase for Foment

set(RECIPE_FOMENT
    STEP "Build" MAKE -C unix
    STEP "Test" MAKE -C unix test
    STEP "Install" ${CMAKE_COMMAND} -E copy unix/debug/foment __INSTALL_PREFIX__/bin/foment
)
