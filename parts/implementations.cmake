# Build 
#
# INPUT:
#   YUNIBASE_ROOT_CURRENT : Path to current base
#   YUNIBASE_ROOT_STABLE : Path to stable base
#   YUNIBASE_BUILD_STABLE_PREFIX : Install path (stable)
#   YUNIBASE_BUILD_CURRENT_PREFIX : Install path (current)

# Guile (current)
set(GUILE_MAKE make)
set(GUILE_MAKE_OPTS "")
set(guile_current_src ${YUNIBASE_ROOT_CURRENT}/guile)
set(GUILE_INSTALL_PREFIX ${YUNIBASE_BUILD_CURRENT_PREFIX}/guile)
build_recipe(guile_current ${guile_current_src}
    GUILE "" ${RECIPE_GUILE})
register_recipe(GUILE CURRENT guile_current)

# Sagittarius (stable + current)
set(SAGITTARIUS_MAKE make)
set(SAGITTARIUS_MAKE_OPTS "")
set(sagittarius_stable_src ${YUNIBASE_ROOT_STABLE}/sagittarius)
set(sagittarius_current_src ${YUNIBASE_ROOT_CURRENT}/sagittarius)
set(SAGITTARIUS_INSTALL_PREFIX 
    ${YUNIBASE_BUILD_STABLE_PREFIX}/sagittarius)
build_recipe(sagittarius_stable ${sagittarius_stable_src}
    SAGITTARIUS "" ${RECIPE_SAGITTARIUS})
set(SAGITTARIUS_INSTALL_PREFIX # RESET
    ${YUNIBASE_BUILD_CURRENT_PREFIX}/sagittarius)
set(ENVP_SAGITTARIUS_BOOTSTRAP
    PATH ${YUNIBASE_BUILD_STABLE_PREFIX}/sagittarius/bin
    LD_LIBRARY_PATH ${YUNIBASE_BUILD_STABLE_PREFIX}/sagittarius/lib)
build_recipe(sagittarius_current ${sagittarius_current_src}
    SAGITTARIUS "${ENVP_SAGITTARIUS_BOOTSTRAP}" ${BOOTSTRAP_SAGITTARIUS})
add_dependencies(sagittarius_current sagittarius_stable)
register_recipe(SAGITTARIUS STABLE sagittarius_stable)
register_recipe(SAGITTARIUS CURRENT sagittarius_current)

# Gauche (stable + current)
set(GAUCHE_MAKE make)
set(GAUCHE_MAKE_OPTS "")
set(gauche_current_src ${YUNIBASE_ROOT_CURRENT}/gauche)
set(gauche_src_stable ${YUNIBASE_ROOT_STABLE}/gauche)
set(GAUCHE_INSTALL_PREFIX ${YUNIBASE_BUILD_STABLE_PREFIX}/gauche)
build_recipe(gauche_stable ${gauche_src_stable} 
    GAUCHE "" ${RECIPE_GAUCHE})

set(ENVP_GAUCHE # Use stable on build-current
    PATH ${YUNIBASE_BUILD_STABLE_PREFIX}/gauche/bin
    LD_LIBRARY_PATH ${YUNIBASE_BUILD_STABLE_PREFIX}/gauche/lib)
set(GAUCHE_INSTALL_PREFIX ${YUNIBASE_BUILD_CURRENT_PREFIX}/gauche) # RESET
build_recipe(gauche_current ${gauche_current_src} 
    GAUCHE "${ENVP_GAUCHE}" ${BOOTSTRAP_GAUCHE})
add_dependencies(gauche_current gauche_stable)

register_recipe(GAUCHE STABLE gauche_stable)
register_recipe(GAUCHE CURRENT gauche_current)

# NMosh (stable)
set(NMOSH_MAKE make)
set(NMOSH_INSTALL_PREFIX ${YUNIBASE_BUILD_STABLE_PREFIX}/nmosh)
set(NMOSH_MAKE_OPTS "")
set(nmosh_src_stable ${YUNIBASE_ROOT_STABLE}/nmosh)
build_recipe(nmosh_stable ${nmosh_src_stable} NMOSH "" ${RECIPE_NMOSH})

register_recipe(NMOSH STABLE nmosh_stable)

# Chibi scheme (current)
set(CHIBI_SCHEME_MAKE make)
set(CHIBI_SCHEME_INSTALL_PREFIX ${YUNIBASE_BUILD_CURRENT_PREFIX}/chibi-scheme)
set(CHIBI_SCHEME_MAKE_OPTS "")
set(chibi_scheme_current_src ${YUNIBASE_ROOT_CURRENT}/chibi-scheme)
build_recipe(chibi_scheme_current
    ${chibi_scheme_current_src}
    CHIBI_SCHEME
    ""
    ${RECIPE_CHIBI_SCHEME})

register_recipe(CHIBI_SCHEME CURRENT chibi_scheme_current)

# Racket (current)
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

register_recipe(RACKET CURRENT racket_current_setup)

# Vicare (current)
set(VICARE_MAKE make)
set(VICARE_INSTALL_PREFIX ${YUNIBASE_BUILD_CURRENT_PREFIX}/vicare)
set(VICARE_MAKE_OPTS "")
set(vicare_current_src ${YUNIBASE_ROOT_CURRENT}/vicare)
build_recipe(vicare_current
    ${vicare_current_src}
    VICARE
    ""
    ${RECIPE_VICARE})

register_recipe(VICARE CURRENT vicare_current)

# Chicken (stable + current)
set(CHICKEN_MAKE make)
set(CHICKEN_INSTALL_PREFIX ${YUNIBASE_BUILD_STABLE_PREFIX}/chicken)
set(chicken_stable_src ${YUNIBASE_ROOT_STABLE}/chicken)
build_recipe(chicken_stable ${chicken_stable_src}
    CHICKEN "" ${RECIPE_CHICKEN})
build_recipe(chicken_stable_test ${chicken_stable_src}
    CHICKEN "" ${RECIPE_CHICKEN_TEST})
add_dependencies(chicken_stable_test chicken_stable)
set(ENVP_CHICKEN_SETUP
    PATH ${CHICKEN_INSTALL_PREFIX}/bin
    LD_LIBRARY_PATH ${CHICKEN_INSTALL_PREFIX}/lib)
build_recipe(chicken_stable_setup ${chicken_stable_src}
    CHICKEN "${ENVP_CHICKEN_SETUP}" ${RECIPE_CHICKEN_SETUP})
add_dependencies(chicken_stable_setup chicken_stable_test)

register_recipe(CHICKEN STABLE chicken_stable_setup)

set(CHICKEN_INSTALL_PREFIX ${YUNIBASE_BUILD_CURRENT_PREFIX}/chicken) # RESET
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
add_dependencies(chicken_current chicken_stable_setup)
add_dependencies(chicken_current_test chicken_current)
build_recipe(chicken_current_setup ${chicken_current_src}
    CHICKEN "${ENVP_CHICKEN_SETUP}" ${RECIPE_CHICKEN_SETUP})
add_dependencies(chicken_current_setup chicken_current_test)

register_recipe(CHICKEN CURRENT chicken_current_setup)
