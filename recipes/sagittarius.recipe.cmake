if(APPLE)
    set(RECIPEPART_SAGITTARIUS_INSTALL_HELPER
        STEP "NameTool" ${CMAKE_COMMAND} -DPTH=__INSTALL_PREFIX__ 
        -P ${CMAKE_CURRENT_LIST_DIR}/../scripts/sagittarius-setup-helper-macos.cmake)
else()
    set(RECIPEPART_SAGITTARIUS_INSTALL_HELPER)
endif()

set(RECIPE_SAGITTARIUS # Recipe for Sagittarius
    STEP "Configure" ${CMAKE_COMMAND} "." "-DCMAKE_INSTALL_PREFIX=__INSTALL_PREFIX__"
    # FIXME: Use CMake --build here.
    STEP "Build"     MAKE __MAKE_PARALLEL__ __MAKE_OPTS__
    STEP "Test"      MAKE test TIMEOUT:600
    STEP "Install"   MAKE install
    ${RECIPEPART_SAGITTARIUS_INSTALL_HELPER}
)

set(BOOTSTRAP_SAGITTARIUS # Bootstrap for Sagittarius
    STEP "Bootstrap" "./dist.sh" gen
)

list(APPEND BOOTSTRAP_SAGITTARIUS ${RECIPE_SAGITTARIUS})
