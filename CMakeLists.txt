# root CMakeLists
# 
# INPUTs:
#
#  YUNIBASE_ONLY: Enable single implementation. 
#    YUNIBASE_ONLY=GAUCHE
#    YUNIBASE_ONLY=GAUCHE_STABLE
#
project(yunibase)
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

# Source definitions
init_config_directory()
init_git_repositories() # Begin list-of repositories
include(./impl-stable/sources.cmake)
include(./sources-current.cmake)

init_recipe() # Begin list-of recipes
include(./parts/implementations.cmake)
create_git_repository_handlers()

# Configure default build

if(YUNIBASE_ONLY)
    enable_recipe_only(${YUNIBASE_ONLY})
else()
    # Build all
    enable_recipe(SAGITTARIUS STABLE)
    enable_recipe(SAGITTARIUS CURRENT)
    enable_recipe(GUILE CURRENT IGNORE_TEST_FAILURE)
    enable_recipe(GAUCHE STABLE)
    enable_recipe(GAUCHE CURRENT)
    enable_recipe(CHIBI_SCHEME CURRENT)
    enable_recipe(RACKET CURRENT)
    enable_recipe(NMOSH STABLE IGNORE_TEST_FAILURE)
    enable_recipe(VICARE CURRENT IGNORE_TEST_FAILURE)
    enable_recipe(CHICKEN STABLE SKIP_TEST)
    # enable_recipe(CHICKEN CURRENT)
    if(YUNIBASE_EXCEPT)
        disable_recipe_only(${YUNIBASE_EXCEPT})
    endif()
endif()


if(YUNIBASE_ONLY)
    message(STATUS "")
    message(STATUS "YUNIBASE_ONLY = ${YUNIBASE_ONLY}")
    message(STATUS "  (Test Mode: Only these implementation(s) enabled.)")
    message(STATUS "")
else()
    if(YUNIBASE_EXCEPT)
        message(STATUS "")
        message(STATUS "YUNIBASE_EXCEPT = ${YUNIBASE_EXCEPT}")
        message(STATUS "")
    else()
        message(STATUS "")
        message(STATUS "(Integration build mode. Use YUNIBASE_ONLY to select")
        message(STATUS " implementation(s) to be built.)")
        message(STATUS "")
    endif()
endif()

