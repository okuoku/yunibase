set(RECIPE_GAUCHE # Recipe for Gauche 
    STEP "Configure" "./configure" "--prefix=__INSTALL_PREFIX__"
    __AUTOCONF_OPTS__
    STEP "Build"     MAKE __MAKE_OPTS__
    STEP "Test"      MAKE check
    STEP "Install"   MAKE install
)

set(BOOTSTRAP_GAUCHE # Recipe for Gauche 
    STEP "Bootstrap" "./DIST" gen
)

list(APPEND BOOTSTRAP_GAUCHE ${RECIPE_GAUCHE})
