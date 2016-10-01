# Recipe for picrin
# There is no bootstrap phase for picrin
set(RECIPE_PICRIN
    STEP "Mkdir" ${CMAKE_COMMAND} -E make_directory __INSTALL_PREFIX__/bin
    STEP "Prebuild" MAKE clean
    STEP "Build" MAKE
    STEP "Install" MAKE install "prefix=__INSTALL_PREFIX__"
)
