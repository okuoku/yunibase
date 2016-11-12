set(RECIPE_VICARE
    STEP "Bootstrap" sh "./autogen.sh"
    STEP "Configure" "./configure" "--prefix=__INSTALL_PREFIX__"
    "--enable-maintainer-mode"
    STEP "Build"     MAKE __MAKE_PARALLEL__ __MAKE_OPTS__
    STEP "Test"      MAKE check
    STEP "Install"   MAKE install
)
