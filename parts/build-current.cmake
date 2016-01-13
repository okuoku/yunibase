# Build current branches
#
# INPUT:
#   YUNIBASE_ROOT_STABLE : Path to stable base
#   YUNIBASE_BUILD_STABLE_PREFIX : Install path

# Gauche
set(GAUCHE_MAKE make)
set(GAUCHE_INSTALL_PREFIX ${YUNIBASE_BUILD_CURRENT_PREFIX}/gauche)
set(GAUCHE_MAKE_OPTS "")
set(gauche_current_src ${YUNIBASE_ROOT_CURRENT}/gauche)
set(ENVP_GAUCHE
    PATH ${YUNIBASE_BUILD_STABLE_PREFIX}/gauche/bin
    LD_LIBRARY_PATH ${YUNIBASE_BUILD_STABLE_PREFIX}/gauche/lib)
build_recipe(gauche_current ${gauche_current_src} GAUCHE "${ENVP_GAUCHE}" ${BOOTSTRAP_GAUCHE})
add_dependencies(gauche_current gauche_stable)

# Chibi scheme
set(CHIBI_SCHEME_MAKE make)
set(CHIBI_SCHEME_INSTALL_PREFIX ${YUNIBASE_BUILD_CURRENT_PREFIX}/chibi-scheme)
set(CHIBI_SCHEME_MAKE_OPTS "")
set(chibi_scheme_current_src ${YUNIBASE_ROOT_CURRENT}/chibi-scheme)
build_recipe(chibi_scheme_current
    ${chibi_scheme_current_src}
    CHIBI_SCHEME
    ""
    ${RECIPE_CHIBI_SCHEME})

# Racket
set(RACKET_MAKE make)
set(RACKET_INSTALL_PREFIX ${YUNIBASE_BUILD_CURRENT_PREFIX}/racket)
set(RACKET_MAKE_OPTS "")
set(racket_current_src ${YUNIBASE_ROOT_CURRENT}/racket/racket/src)
set(ENVP_RACKET_SETUP
    PATH ${YUNIBASE_BUILD_CURRENT_PREFIX}/racket/bin
    LD_LIBRARY_PATH ${YUNIBASE_BUILD_CURRENT_PREFIX}/racket/lib)
build_recipe(racket_current
    ${racket_current_src}
    RACKET
    ""
    ${RECIPE_RACKET})
build_recipe(racket_current_setup
    ${racket_current_src}
    RACKET
    "${ENVP_RACKET_SETUP}"
    ${RECIPE_RACKET_SETUP})
add_dependencies(racket_current_setup racket_current)

# Vicare 
set(VICARE_MAKE make)
set(VICARE_INSTALL_PREFIX ${YUNIBASE_BUILD_CURRENT_PREFIX}/vicare)
set(VICARE_MAKE_OPTS "")
set(vicare_current_src ${YUNIBASE_ROOT_CURRENT}/vicare)
build_recipe(vicare_current
    ${vicare_current_src}
    VICARE
    ""
    ${RECIPE_VICARE})

# Chicken (disabled)
if(FALSE)
set(CHICKEN_MAKE make)
set(CHICKEN_INSTALL_PREFIX ${YUNIBASE_BUILD_CURRENT_PREFIX}/chicken)
set(chicken_current_src ${YUNIBASE_ROOT_CURRENT}/chicken)
set(ENVP_CHICKEN_BUILD
    PATH ${YUNIBASE_BUILD_STABLE_PREFIX}/chicken/bin
    LD_LIBRARY_PATH ${YUNIBASE_BUILD_STABLE_PREFIX}/chicken/lib)
set(ENVP_CHICKEN_SETUP
    PATH ${YUNIBASE_BUILD_CURRENT_PREFIX}/chicken/bin
    LD_LIBRARY_PATH ${YUNIBASE_BUILD_CURRENT_PREFIX}/chicken/lib)
build_recipe(chicken_current ${chicken_current_src}
    CHICKEN "${ENVP_CHICKEN_BUILD}" ${RECIPE_CHICKEN})
build_recipe(chicken_current_test ${chicken_current_src}
    CHICKEN "${ENVP_CHICKEN_SETUP}" ${RECIPE_CHICKEN_TEST})
add_dependencies(chicken_current_test chicken_current)
build_recipe(chicken_current_setup ${chicken_current_src}
    CHICKEN "${ENVP_CHICKEN_SETUP}" ${RECIPE_CHICKEN_SETUP})
add_dependencies(chicken_current_setup chicken_current_test)
endif()
