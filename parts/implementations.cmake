# Build 
#
# INPUT:
#   YUNIBASE_ROOT_CURRENT : Path to current base
#   YUNIBASE_ROOT_STABLE : Path to stable base
#   YUNIBASE_BUILD_STABLE_PREFIX : Install path (stable)
#   YUNIBASE_BUILD_CURRENT_PREFIX : Install path (current)

# Guile (current)
set(guile_current_src ${YUNIBASE_ROOT_CURRENT}/guile)
set(guile_current_dest ${YUNIBASE_BUILD_CURRENT_PREFIX}/guile)
build_recipe(guile_current ${guile_current_src} ${guile_current_dest}
    GUILE "" ${RECIPE_GUILE})
register_recipe(GUILE CURRENT guile_current)

# Sagittarius (stable + current)
set(sagittarius_stable_src ${YUNIBASE_ROOT_STABLE}/sagittarius)
set(sagittarius_current_src ${YUNIBASE_ROOT_CURRENT}/sagittarius)
set(sagittarius_stable_dest
    ${YUNIBASE_BUILD_STABLE_PREFIX}/sagittarius)
set(sagittarius_current_dest
    ${YUNIBASE_BUILD_CURRENT_PREFIX}/sagittarius)
build_recipe(sagittarius_stable ${sagittarius_stable_src}
    ${sagittarius_stable_dest}
    SAGITTARIUS "" ${RECIPE_SAGITTARIUS})
set(ENVP_SAGITTARIUS_BOOTSTRAP
    PATH ${YUNIBASE_BUILD_STABLE_PREFIX}/sagittarius/bin
    LD_LIBRARY_PATH ${YUNIBASE_BUILD_STABLE_PREFIX}/sagittarius/lib)
build_recipe(sagittarius_current ${sagittarius_current_src}
    ${sagittarius_current_dest}
    SAGITTARIUS "${ENVP_SAGITTARIUS_BOOTSTRAP}" ${BOOTSTRAP_SAGITTARIUS})
add_dependencies(sagittarius_current sagittarius_stable)
register_recipe(SAGITTARIUS STABLE sagittarius_stable)
register_recipe(SAGITTARIUS CURRENT sagittarius_current)

# Gauche (stable + current)
set(gauche_current_src ${YUNIBASE_ROOT_CURRENT}/gauche)
set(gauche_stable_src ${YUNIBASE_ROOT_STABLE}/gauche)
set(gauche_stable_dest ${YUNIBASE_BUILD_STABLE_PREFIX}/gauche)
build_recipe(gauche_stable ${gauche_stable_src}  ${gauche_stable_dest}
    GAUCHE "" ${RECIPE_GAUCHE})

set(ENVP_GAUCHE # Use stable on build-current
    PATH ${YUNIBASE_BUILD_STABLE_PREFIX}/gauche/bin
    LD_LIBRARY_PATH ${YUNIBASE_BUILD_STABLE_PREFIX}/gauche/lib)
set(gauche_current_dest ${YUNIBASE_BUILD_CURRENT_PREFIX}/gauche)
build_recipe(gauche_current ${gauche_current_src} ${gauche_current_dest}
    GAUCHE "${ENVP_GAUCHE}" ${BOOTSTRAP_GAUCHE})
add_dependencies(gauche_current gauche_stable)

register_recipe(GAUCHE STABLE gauche_stable)
register_recipe(GAUCHE CURRENT gauche_current)

# NMosh (stable)
set(nmosh_stable_src ${YUNIBASE_ROOT_STABLE}/nmosh)
set(nmosh_stable_dest ${YUNIBASE_BUILD_STABLE_PREFIX}/nmosh)
build_recipe(nmosh_stable ${nmosh_stable_src} ${nmosh_stable_dest}
    NMOSH "" ${RECIPE_NMOSH})

register_recipe(NMOSH STABLE nmosh_stable)
workaround_touch_prebuilt_files(
    ${nmosh_stable_src}
    src/Instruction.h
    src/main.cpp
    src/labels.cpp
    src/cprocedures.cpp
    src/all-tests.scm
    src/Object-accessors.h
    src/OSConstants.h
    src/Reader.tab.cpp
    src/Reader.tab.hpp
    src/NumberReader.tab.cpp
    src/NumberReader.tab.hpp
    src/Scanner.cpp
    src/NumberScanner.cpp)

# Chibi scheme (current)
set(chibi_scheme_current_src ${YUNIBASE_ROOT_CURRENT}/chibi-scheme)
set(chibi_scheme_current_dest ${YUNIBASE_BUILD_CURRENT_PREFIX}/chibi-scheme)
build_recipe(chibi_scheme_current
    ${chibi_scheme_current_src}
    ${chibi_scheme_current_dest}
    CHIBI_SCHEME
    ""
    ${RECIPE_CHIBI_SCHEME})

register_recipe(CHIBI_SCHEME CURRENT chibi_scheme_current)

# Racket (current)
set(racket_current_src ${YUNIBASE_ROOT_CURRENT}/racket/racket/src)
set(racket_current_dest ${YUNIBASE_BUILD_CURRENT_PREFIX}/racket)
set(ENVP_RACKET_SETUP
    PATH ${YUNIBASE_BUILD_CURRENT_PREFIX}/racket/bin
    LD_LIBRARY_PATH ${YUNIBASE_BUILD_CURRENT_PREFIX}/racket/lib)
build_recipe(racket_current
    ${racket_current_src}
    ${racket_current_dest}
    RACKET
    ""
    ${RECIPE_RACKET})
build_recipe(racket_current_setup
    ${racket_current_src}
    ${racket_current_dest}
    RACKET
    "${ENVP_RACKET_SETUP}"
    ${RECIPE_RACKET_SETUP})

register_recipe(RACKET CURRENT 
    racket_current
    racket_current_setup)

# Vicare (current)
set(vicare_current_src ${YUNIBASE_ROOT_CURRENT}/vicare)
set(vicare_current_dest ${YUNIBASE_BUILD_CURRENT_PREFIX}/vicare)
build_recipe(vicare_current
    ${vicare_current_src}
    ${vicare_current_dest}
    VICARE
    ""
    ${RECIPE_VICARE})

register_recipe(VICARE CURRENT vicare_current)

# Chicken (stable + current)
set(chicken_stable_src ${YUNIBASE_ROOT_STABLE}/chicken)
set(chicken_stable_dest ${YUNIBASE_BUILD_STABLE_PREFIX}/chicken)
build_recipe(chicken_stable ${chicken_stable_src} ${chicken_stable_dest}
    CHICKEN "" ${RECIPE_CHICKEN})
build_recipe(chicken_stable_test ${chicken_stable_src} ${chicken_stable_dest}
    CHICKEN "" ${RECIPE_CHICKEN_TEST})
set(ENVP_CHICKEN_SETUP
    PATH ${CHICKEN_INSTALL_PREFIX}/bin
    LD_LIBRARY_PATH ${CHICKEN_INSTALL_PREFIX}/lib)
build_recipe(chicken_stable_setup ${chicken_stable_src} ${chicken_stable_dest}
    CHICKEN "${ENVP_CHICKEN_SETUP}" ${RECIPE_CHICKEN_SETUP})

register_recipe(CHICKEN STABLE 
    chicken_stable
    chicken_stable_setup
    chicken_stable_test)

set(chicken_current_src ${YUNIBASE_ROOT_CURRENT}/chicken)
set(chicken_current_dest ${YUNIBASE_BUILD_CURRENT_PREFIX}/chicken)
set(ENVP_CHICKEN_BUILD
    PATH ${YUNIBASE_BUILD_STABLE_PREFIX}/chicken/bin
    LD_LIBRARY_PATH ${YUNIBASE_BUILD_STABLE_PREFIX}/chicken/lib)
set(ENVP_CHICKEN_SETUP
    PATH ${YUNIBASE_BUILD_CURRENT_PREFIX}/chicken/bin
    LD_LIBRARY_PATH ${YUNIBASE_BUILD_CURRENT_PREFIX}/chicken/lib)
build_recipe(chicken_current ${chicken_current_src} ${chicken_current_dest}
    CHICKEN "${ENVP_CHICKEN_BUILD}" ${RECIPE_CHICKEN})
build_recipe(chicken_current_test ${chicken_current_src} ${chicken_current_dest}
    CHICKEN "${ENVP_CHICKEN_SETUP}" ${RECIPE_CHICKEN_TEST})
add_dependencies(chicken_current chicken_stable_setup)
build_recipe(chicken_current_setup 
    ${chicken_current_src} 
    ${chicken_current_dest}
    CHICKEN "${ENVP_CHICKEN_SETUP}" ${RECIPE_CHICKEN_SETUP})

register_recipe(CHICKEN CURRENT 
    chicken_current
    chicken_current_setup
    chicken_current_test)
