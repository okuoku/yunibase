# Recipe for Kawa
# There is no bootstrap/test phase for kawa.

set(RECIPE_KAWA
    STEP "Build" ant -Ddist.kawa.jar=kawa.jar
    STEP "Postbuild" mkdir -p __INSTALL_PREFIX__
    STEP "Install" cp kawa.jar __INSTALL_PREFIX__
)
