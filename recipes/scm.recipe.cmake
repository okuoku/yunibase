set(RECIPE_SCM
    STEP "Configure"
    "./configure" "--prefix=__INSTALL_PREFIX__"
    __AUTOCONF_OPTS__
    STEP "BuildScmLit"
    make scmlit
    STEP "Build"
    make all
    STEP "Install"
    make install)
set(RECIPE_SLIB
    STEP "Configure"
    "./configure" "--prefix=__INSTALL_PREFIX__"
    STEP "Install"
    make install)

