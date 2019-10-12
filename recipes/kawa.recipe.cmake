# Recipe for Kawa
# There is no bootstrap/test phase for kawa.

set(RECIPE_KAWA
    STEP "Automake" ./autogen.sh
    STEP "Configure" ./configure "--prefix=__INSTALL_PREFIX__"
    STEP "Build" make __MAKE_PARALLEL__ __MAKE_OPTS__
    STEP "Install" make install
)
