if(APPLE)
    set(racket_xon_x "--enable-xonx")
else()
    set(racket_xon_x)
endif()
set(RECIPE_RACKET # We do not support in-tree tests yet
    STEP "Configure" "./configure" "--prefix=__INSTALL_PREFIX__"
    ${racket_xon_x}
    STEP "Build" MAKE __MAKE_OPTS__
    STEP "Install" MAKE install
    )

set(RECIPE_RACKET_SETUP
    STEP "SetupR6RS" raco pkg install --skip-installed --scope installation --auto r6rs-lib TIMEOUT:1000
    STEP "SetupSRFI" raco pkg install --skip-installed --scope installation --auto srfi-lib TIMEOUT:1000
    )

