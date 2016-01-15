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
set(YUNIBASE_ROOT ${CMAKE_CURRENT_LIST_DIR})

include(YunibaseBuildManager)
include(YunibaseRecipe)

set(YUNIBASE_ROOT_STABLE ${CMAKE_CURRENT_LIST_DIR}/impl-stable)
set(YUNIBASE_ROOT_CURRENT ${CMAKE_CURRENT_LIST_DIR}/impl-current)

set(YUNIBASE_BUILD_STABLE_PREFIX
    ${CMAKE_CURRENT_BINARY_DIR}/stable)
set(YUNIBASE_BUILD_CURRENT_PREFIX
    ${CMAKE_CURRENT_BINARY_DIR}/current)

# Instanciate recipes

include(./recipes/nmosh.recipe.cmake)
include(./recipes/gauche.recipe.cmake)
include(./recipes/chibi-scheme.recipe.cmake)
include(./recipes/racket.recipe.cmake)
include(./recipes/chicken.recipe.cmake)
include(./recipes/vicare.recipe.cmake)

init_recipe()
include(./parts/implementations.cmake)

# Configure build

if(YUNIBASE_ONLY)
    enable_recipe_only(${YUNIBASE_ONLY})
else()
    # Build all
    enable_recipe(GAUCHE STABLE)
    enable_recipe(GAUCHE CURRENT)
    # enable_recipe(NMOSH STABLE)
    enable_recipe(CHIBI_SCHEME CURRENT)
    enable_recipe(RACKET CURRENT)
    # enable_recipe(VICARE CURRENT)
    # enable_recipe(CHICKEN STABLE)
    # enable_recipe(CHICKEN CURRENT)
endif()
