# root CMakeLists
# 
# INPUTs:
#
#  YUNIBASE_ONLY: Enable some implementations. 
#    YUNIBASE_ONLY=GAUCHE
#    YUNIBASE_ONLY=GAUCHE_STABLE
#
#  YUNIBASE_EXCEPT: Disable some implementations. 
#
#  YUNIBASE_BOOTSTRAP_ONLY: Only bootstrap the tree
#
#  YUNIBASE_POSTBOOTSTRAP: Assumes tree was bootstrapped
#
project(yunibase NONE)
cmake_minimum_required(VERSION 2.8)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)

# 
# Global Variables
#
# Used in RecipeRunner
set(YUNIBASE_ROOT ${CMAKE_CURRENT_LIST_DIR})
set(YUNIBASE_BUILD_CONFIG_PREFIX ${CMAKE_CURRENT_BINARY_DIR}/config) 
set(YUNIBASE_BUILD_REPORT_PREFIX ${CMAKE_CURRENT_BINARY_DIR}/reports) 
set(YUNIBASE_BUILD_LOG_PREFIX ${CMAKE_CURRENT_BINARY_DIR}/logs)

# Defaults
set(YUNIBASE_ROOT_STABLE ${CMAKE_CURRENT_LIST_DIR}/impl-stable)
set(YUNIBASE_ROOT_CURRENT ${CMAKE_CURRENT_LIST_DIR}/impl-current)
set(YUNIBASE_BUILD_STABLE_PREFIX
    ${CMAKE_CURRENT_BINARY_DIR}/stable)
set(YUNIBASE_BUILD_CURRENT_PREFIX
    ${CMAKE_CURRENT_BINARY_DIR}/current)

include(YunibaseWorkaroundFileTimestamp)
include(YunibaseRecipe)
include(YunibaseBuildManager)
include(YunibaseUpdateManager) # Depends on Recipe/Build
include(YunibaseSourceManager) # Depends on UpdateMgr


# Instanciate recipe templates
include(./recipes/nmosh.recipe.cmake)
include(./recipes/gauche.recipe.cmake)
include(./recipes/chibi-scheme.recipe.cmake)
include(./recipes/racket.recipe.cmake)
include(./recipes/chicken.recipe.cmake)
include(./recipes/vicare.recipe.cmake)
include(./recipes/guile.recipe.cmake)
include(./recipes/sagittarius.recipe.cmake)
include(./recipes/kawa.recipe.cmake)

# Source definitions
init_sources()
init_config_directory()
init_git_repositories() # Begin list-of repositories
include(./impl-stable/sources.cmake)
include(./sources-current.cmake)

init_recipe() # Begin list-of recipes
include(./parts/implementations.cmake)
create_git_repository_handlers()

if(CYGWIN)
    set(allow_testfail_cygwin IGNORE_TEST_FAILURE)
    set(skip_test_cygwin SKIP_TEST)
else()
    set(allow_testfail_cygwin)
    set(skip_test_cygwin)
endif()

# Configure default build
if(YUNIBASE_BOOTSTRAP_ONLY)
    # Build only STABLEs and bootstrap.
    # Saggitarius, Gauche, Guile, Vicare
    # FIXME: Chicken has no separate bootstrap phase.
    # Including VM generations
    activate_recipe(SAGITTARIUS STABLE SKIP_TEST)
    activate_recipe(SAGITTARIUS CURRENT BOOTSTRAP_ONLY)
    activate_recipe(GAUCHE STABLE SKIP_TEST)
    activate_recipe(GAUCHE CURRENT BOOTSTRAP_ONLY)
    # Just for autotools
    activate_recipe(GUILE CURRENT BOOTSTRAP_ONLY)
    activate_recipe(VICARE CURRENT BOOTSTRAP_ONLY)
elseif(YUNIBASE_POSTBOOTSTRAP)
    # Build only CURRENT flavors
    # FIXME: Chicken has no separate bootstrap phase.
    # We skip most STABLE flavor except NMosh here.
    activate_recipe(SAGITTARIUS CURRENT SKIP_BOOTSTRAP ${skip_test_cygwin})
    activate_recipe(GUILE CURRENT IGNORE_TEST_FAILURE SKIP_BOOTSTRAP)
    activate_recipe(GAUCHE CURRENT SKIP_BOOTSTRAP ${allow_testfail_cygwin})
    activate_recipe(CHIBI_SCHEME CURRENT)
    activate_recipe(RACKET CURRENT)
    activate_recipe(NMOSH STABLE IGNORE_TEST_FAILURE)
    activate_recipe(VICARE CURRENT IGNORE_TEST_FAILURE SKIP_BOOTSTRAP)
else()
    # Build all (stable + bootstrap + current)
    activate_recipe(SAGITTARIUS STABLE SKIP_TEST)
    activate_recipe(SAGITTARIUS CURRENT ${skip_test_cygwin})
    activate_recipe(GUILE CURRENT IGNORE_TEST_FAILURE)
    activate_recipe(GAUCHE STABLE ${allow_testfail_cygwin})
    activate_recipe(GAUCHE CURRENT ${allow_testfail_cygwin})
    activate_recipe(CHIBI_SCHEME CURRENT)
    activate_recipe(RACKET CURRENT)
    activate_recipe(NMOSH STABLE IGNORE_TEST_FAILURE)
    activate_recipe(VICARE CURRENT IGNORE_TEST_FAILURE)
    activate_recipe(CHICKEN STABLE SKIP_TEST)
    activate_recipe(CHICKEN CURRENT SKIP_TEST)
    activate_recipe(KAWA CURRENT)
endif()

if(YUNIBASE_ONLY)
    enable_recipe_only(${YUNIBASE_ONLY})
endif()

if(YUNIBASE_EXCEPT)
    disable_recipe_only(${YUNIBASE_EXCEPT})
endif()

if(YUNIBASE_EXCEPT)
    message(STATUS "")
    message(STATUS "YUNIBASE_EXCEPT = ${YUNIBASE_EXCEPT}")
endif()

if(YUNIBASE_ONLY)
    message(STATUS "")
    message(STATUS "YUNIBASE_ONLY = ${YUNIBASE_ONLY}")
endif()
