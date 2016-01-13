# Build stable branches
#
# INPUT:
#   YUNIBASE_ROOT_STABLE : Path to stable base
#   YUNIBASE_BUILD_STABLE_PREFIX : Install path

# Gauche
set(GAUCHE_MAKE make)
set(GAUCHE_INSTALL_PREFIX ${YUNIBASE_BUILD_STABLE_PREFIX}/gauche)
set(GAUCHE_MAKE_OPTS "")
set(gauche_src_stable ${YUNIBASE_ROOT_STABLE}/gauche)
build_recipe(gauche_stable ${gauche_src_stable} GAUCHE "" ${RECIPE_GAUCHE})

# NMosh (disabled)
set(NMOSH_MAKE make)
set(NMOSH_INSTALL_PREFIX ${YUNIBASE_BUILD_STABLE_PREFIX}/nmosh)
set(NMOSH_MAKE_OPTS "")
set(nmosh_src_stable ${YUNIBASE_ROOT_STABLE}/nmosh)
# build_recipe(nmosh_stable ${nmosh_src_stable} NMOSH "" ${RECIPE_NMOSH})

# Chicken
set(CHICKEN_MAKE make)
set(CHICKEN_INSTALL_PREFIX ${YUNIBASE_BUILD_STABLE_PREFIX}/chicken)
set(chicken_src_stable ${YUNIBASE_ROOT_STABLE}/chicken)
build_recipe(chicken_stable ${chicken_src_stable}
    CHICKEN "" ${RECIPE_CHICKEN})
build_recipe(chicken_stable_test ${chicken_src_stable}
    CHICKEN "" ${RECIPE_CHICKEN_TEST})
add_dependencies(chicken_stable_test chicken_stable)
set(ENVP_CHICKEN_SETUP
    PATH ${CHICKEN_INSTALL_PREFIX}/bin
    LD_LIBRARY_PATH ${CHICKEN_INSTALL_PREFIX}/lib)
build_recipe(chicken_stable_setup ${chicken_src_stable}
    CHICKEN "${ENVP_CHICKEN_SETUP}" ${RECIPE_CHICKEN_SETUP})
add_dependencies(chicken_stable_setup chicken_stable_test)
