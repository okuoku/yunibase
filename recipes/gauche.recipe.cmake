set(RECIPE_GAUCHE # Receipe for Gauche 
    STEP "Configure" "./configure" "--prefix=__INSTALL_PREFIX__"
    STEP "Build"     MAKE __MAKE_OPTS__
    STEP "Test"      MAKE check
    STEP "Install"   MAKE install
)

set(BOOTSTRAP_GAUCHE # Receipe for Gauche 
    STEP "Bootstrap" "./DIST" gen
)

list(APPEND BOOTSTRAP_GAUCHE ${RECIPE_GAUCHE})
