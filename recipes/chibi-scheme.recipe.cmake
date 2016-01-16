# Recipe for chibi-scheme
# There is no bootstrap phase for chibi-scheme.
#
# chibi-scheme has alternative test targets:
#
#   test
#   test-all
#   test-dist
# 
# We use test-all here for now.
set(RECIPE_CHIBI_SCHEME 
    STEP "Build" MAKE "PREFIX=__INSTALL_PREFIX__"
    STEP "Test" MAKE test-all "PREFIX=__INSTALL_PREFIX__"
    STEP "Install" MAKE install "PREFIX=__INSTALL_PREFIX__"
)
