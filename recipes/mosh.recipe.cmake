# Mosh test would require:
#
#  setsebool -P selinuxuser_execheap 1
#

set(RECIPE_MOSH_BUILD # Recipe for Mosh
    STEP "Configure" "./configure" "--prefix=__INSTALL_PREFIX__"
    __AUTOCONF_OPTS__
    # It seems we cannot do "chmod -wx" on AUFS..
    # Set as r--rw-rw- instead.
    STEP "CHMOD"     chmod 466 tests/read-only.txt
    STEP "Build"     MAKE __MAKE_OPTS__
    STEP "Test"      MAKE check
    STEP "Install"   MAKE install
)

set(BOOTSTRAP_MOSH
    STEP "Bootstrap" "./gen-git-build.sh"
)
