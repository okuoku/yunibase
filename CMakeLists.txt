# root CMakeLists
# 
# INPUTs:
#
#  YUNIBASE_TARGET_PREFIX: The `yunibase` directory
#
#  YUNIBASE_ONLY: Enable some implementations. 
#    YUNIBASE_ONLY=GAUCHE
#    YUNIBASE_ONLY=GAUCHE_STABLE
#
#  YUNIBASE_EXCEPT: Disable some implementations. 
#
#  YUNIBASE_BOOTSTRAP_ONLY: Only bootstrap the tree 
#                          (prepare for ready-to-build)
#
#  YUNIBASE_POSTBOOTSTRAP: Assumes tree was bootstrapped
#
cmake_minimum_required(VERSION 2.8.4)
project(yunibase NONE)

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
if(YUNIBASE_TARGET_PREFIX)
    set(YUNIBASE_BUILD_STABLE_PREFIX
        ${YUNIBASE_TARGET_PREFIX}/stable)
    set(YUNIBASE_BUILD_CURRENT_PREFIX
        ${YUNIBASE_TARGET_PREFIX}/current)
else()
    set(YUNIBASE_BUILD_STABLE_PREFIX
        ${CMAKE_CURRENT_BINARY_DIR}/stable)
    set(YUNIBASE_BUILD_CURRENT_PREFIX
        ${CMAKE_CURRENT_BINARY_DIR}/current)
endif()

if(APPLE)
    # Perhaps NetBSD and MINIX, too
    set(YUNIBASE_USE_PKGSRC_DEFAULTS TRUE)
else()
    set(YUNIBASE_USE_PKGSRC_DEFAULTS)
endif()

include(YunibaseWorkaroundFileTimestamp)
include(YunibaseWorkaroundFileEdit)
include(YunibaseRecipe)
include(YunibaseBuildManager)
include(YunibaseUpdateManager) # Depends on Recipe/Build
include(YunibaseSourceManager) # Depends on UpdateMgr

# Configure parallel build
include(ProcessorCount)
ProcessorCount(__processor_count)
if(NOT __processor_count EQUAL 0)
    set(YUNIBASE_MAKE_JOBS "${__processor_count}")
else()
    set(YUNIBASE_MAKE_JOBS "1")
endif()

set(YUNIBASE_MAKE_PARALLEL "-j${YUNIBASE_MAKE_JOBS}")

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
include(./recipes/larceny.recipe.cmake)
include(./recipes/chez.recipe.cmake)
include(./recipes/gambit.recipe.cmake)
include(./recipes/rapid-gambit.recipe.cmake)
include(./recipes/picrin.recipe.cmake)
include(./recipes/mit-scheme.recipe.cmake)

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

set(skip_test_wsl)
if(${CMAKE_SYSTEM_PROCESSOR} MATCHES "i?86" AND
        ${CMAKE_SYSTEM_NAME} MATCHES "Linux")
    if(EXISTS /proc/sys/kernel/osrelease)
        # Detect Windows Subsystem on Linux using osrelease
        # Currently, it is "3.4.0-Microsoft".
        file(READ /proc/sys/kernel/osrelease os_release)
        if(${os_release} MATCHES "^([0-9]+)\\.([0-9]+)\\.([0-9]+)-Microsoft")
            message(STATUS "WSL Detected!!")
            set(skip_test_wsl SKIP_TEST)
        else()
            # Normal linux kernel / other emulators
        endif()
    endif()
endif()

# Configure default build
if(YUNIBASE_BOOTSTRAP_ONLY)
    # Build only STABLEs and bootstrap.
    # Saggitarius, Gauche, Guile, Vicare
    # Including VM generations
    #activate_recipe(SAGITTARIUS STABLE SKIP_TEST)
    #activate_recipe(SAGITTARIUS CURRENT BOOTSTRAP_ONLY)
    activate_recipe(GAUCHE STABLE SKIP_TEST)
    activate_recipe(GAUCHE CURRENT BOOTSTRAP_ONLY)
    # Bootstram impl
    activate_recipe(CHICKEN STABLE SKIP_TEST)
    # Just for autotools
    activate_recipe(GUILE CURRENT BOOTSTRAP_ONLY)
    #activate_recipe(VICARE CURRENT BOOTSTRAP_ONLY)
elseif(YUNIBASE_POSTBOOTSTRAP)
    # Build only CURRENT flavors
    # We skip most STABLE flavor except NMosh here.
    # FIXME: Implement boehm-gc installation
    #activate_recipe(SAGITTARIUS CURRENT SKIP_BOOTSTRAP ${skip_test_cygwin})
    #activate_recipe(GUILE CURRENT IGNORE_TEST_FAILURE SKIP_BOOTSTRAP)
    activate_recipe(GAUCHE CURRENT SKIP_BOOTSTRAP ${allow_testfail_cygwin})
    activate_recipe(CHIBI_SCHEME CURRENT)
    activate_recipe(RACKET CURRENT)
    #activate_recipe(NMOSH STABLE IGNORE_TEST_FAILURE)
    activate_recipe(VICARE CURRENT SKIP_TEST SKIP_BOOTSTRAP)
    #activate_recipe(GAMBIT STABLE)
    #activate_recipe(RAPID_GAMBIT CURRENT)
    activate_recipe(PICRIN CURRENT)
else()
    # Build all (stable + bootstrap + current)
    if(NOT APPLE)
        activate_recipe(KAWA CURRENT)
        activate_recipe(VICARE CURRENT SKIP_TEST)
    endif()
    activate_recipe(SAGITTARIUS STABLE SKIP_TEST)
    activate_recipe(SAGITTARIUS CURRENT 
        ${skip_test_cygwin} ${skip_test_wsl})
    activate_recipe(GUILE CURRENT IGNORE_TEST_FAILURE)
    activate_recipe(GAUCHE STABLE SKIP_TEST)
    activate_recipe(GAUCHE CURRENT ${allow_testfail_cygwin} ${skip_test_wsl})
    activate_recipe(CHIBI_SCHEME CURRENT)
    activate_recipe(RACKET CURRENT)
    activate_recipe(NMOSH STABLE IGNORE_TEST_FAILURE)
    activate_recipe(CHICKEN STABLE SKIP_TEST)
    activate_recipe(CHICKEN CURRENT SKIP_TEST)
    if(${CMAKE_SYSTEM_PROCESSOR} MATCHES "i?86" AND
            ${CMAKE_SYSTEM_NAME} MATCHES "Linux")
        # Larceny currently only available on Linux/i386
        activate_recipe(LARCENY CURRENT)
    endif()
    activate_recipe(CHEZ CURRENT)
    activate_recipe(GAMBIT STABLE)
    activate_recipe(GAMBIT CURRENT)
    activate_recipe(RAPID_GAMBIT CURRENT)
    activate_recipe(PICRIN CURRENT)
    if(${CMAKE_SYSTEM_PROCESSOR} MATCHES "x86_64" AND
            ${CMAKE_SYSTEM_NAME} MATCHES "Linux")
        activate_recipe(MIT_SCHEME STABLE)
        activate_recipe(MIT_SCHEME CURRENT)
    endif()
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

add_buildmgr_report()

register_update_all()
