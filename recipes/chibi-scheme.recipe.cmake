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
if(CMAKE_SYSTEM_NAME STREQUAL DragonFly)
    # Prevent illegal ldconfig run that can cause infinite-loop on non-root
    set(ldconfig "LDCONFIG=NEVERLAND")
else()
    set(ldconfig)
endif()
set(RECIPE_CHIBI_SCHEME 
    STEP "Build" MAKE ${ldconfig} "PREFIX=__INSTALL_PREFIX__"
    STEP "Test" MAKE test-all "PREFIX=__INSTALL_PREFIX__"
    STEP "Install" MAKE install ${ldconfig} "PREFIX=__INSTALL_PREFIX__"
)
