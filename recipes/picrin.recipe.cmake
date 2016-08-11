# Recipe for picrin
# There is no bootstrap phase for picrin
set(RECIPE_PICRIN
    STEP "Prebuild" MAKE clean
    STEP "Build" MAKE
    STEP "Install" MAKE install "prefix=__INSTALL_PREFIX__"
)
