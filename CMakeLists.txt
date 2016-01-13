# root CMakeLists
project(yunibase)
cmake_minimum_required(VERSION 2.8)

option(YUNIBASE_BUILD_STABLE "build implementations (stable branch)" OFF)
option(YUNIBASE_BUILD_CURRENT "build implementations (current)" OFF)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)
set(YUNIBASE_ROOT ${CMAKE_CURRENT_LIST_DIR})

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

if(YUNIBASE_BUILD_STABLE)
    include(./parts/build-stable.cmake)
endif()

if(YUNIBASE_BUILD_CURRENT)
    include(./parts/build-current.cmake)
endif()

