set(RECIPE_SCM
    STEP "Configure"
    "./configure" "--prefix=__INSTALL_PREFIX__"
    STEP "BuildScmLit"
    make scmlit __AUTOCONF_OPTS__
    STEP "Build"
    make all __AUTOCONF_OPTS__
    STEP "Install"
    make install)
set(RECIPE_SLIB
    STEP "Configure"
    "./configure" "--prefix=__INSTALL_PREFIX__"
    STEP "Install"
    make install)

