set(RECIPE_GAUCHE_CONFIGBUILD # Recipe for Gauche 
    STEP "Configure" "./configure" "--prefix=__INSTALL_PREFIX__"
    # Disable iconv since it may conflict on macOS pkgsrc
    --without-iconv
    __AUTOCONF_OPTS__
    STEP "Build"     MAKE __MAKE_OPTS__
)

set(RECIPE_GAUCHE_TESTINSTALL
    #STEP "Test"      MAKE check
    STEP "Install"   MAKE install
)

set(BOOTSTRAP_GAUCHE # Recipe for Gauche 
    STEP "Bootstrap" "./DIST" gen
)

set(RECIPE_GAUCHE_ALL)
list(APPEND RECIPE_GAUCHE_ALL ${RECIPE_GAUCHE_CONFIGBUILD})
list(APPEND RECIPE_GAUCHE_ALL ${RECIPE_GAUCHE_TESTINSTALL})
