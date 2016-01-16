# NMosh test would require:
#
#  setsebool -P selinuxuser_execheap 1
#

set(RECIPE_NMOSH # Recipe for NMosh/Psyntax-mosh
    STEP "Configure" "./configure" "--prefix=__INSTALL_PREFIX__"
    # It seems we cannot do "chmod -wx" on AUFS..
    # Set as r--rw-rw- instead.
    STEP "CHMOD"     chmod 466 tests/read-only.txt
    STEP "Build"     MAKE __MAKE_OPTS__
    STEP "Test"      MAKE check
    STEP "Install"   MAKE install
)
