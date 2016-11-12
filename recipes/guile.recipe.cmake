if(APPLE)
    # autogen.sh assumes we have glibtoolize (not so correct)
    set(RECIPE_GUILE_AUTOGEN autoreconf -ifv)
else()
    set(RECIPE_GUILE_AUTOGEN ./autogen.sh)
endif()
set(RECIPE_GUILE # Recipe for Guile
    STEP "Bootstrap" ${RECIPE_GUILE_AUTOGEN}
    STEP "Configure" "./configure" "--prefix=__INSTALL_PREFIX__"
    STEP "Build"     MAKE __MAKE_PARALLEL__ __MAKE_OPTS__
    # STEP "Test"      MAKE check
    STEP "Install"   MAKE install
)
