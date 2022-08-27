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
#  YUNIBASE_ARCHIVE_TAG: Archive tag (ubuntu, cyg64, ...)
#  YUNIBASE_ARCHIVE_OUTPUT_DIR: Override archive output path
#  YUNIBASE_PREBUILT_STABLE: Archive path to prebuilt stable 
#
#  YUNIBASE_FIX_TIMESTAMPS: Fix timestamps for commited sources
#
#  YUNIBASE_ROOT_STABLE: impl-stable directory
#  YUNIBASE_ROOT_CURRENT: impl-current directory
#
cmake_minimum_required(VERSION 3.0)
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
set(YUNIBASE_YUNIROOT ${CMAKE_CURRENT_LIST_DIR}/yuni)

# Defaults
if(NOT YUNIBASE_ROOT_STABLE)
    set(YUNIBASE_ROOT_STABLE ${CMAKE_CURRENT_LIST_DIR}/impl-stable)
endif()
if(NOT YUNIBASE_ROOT_CURRENT)
    set(YUNIBASE_ROOT_CURRENT ${CMAKE_CURRENT_LIST_DIR}/impl-current)
endif()
set(YUNIBASE_ROOT_RSRC ${CMAKE_CURRENT_LIST_DIR})

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
include(YunibaseArtifactUpload)

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
include(./recipes/chicken5.recipe.cmake)
include(./recipes/vicare.recipe.cmake)
include(./recipes/guile.recipe.cmake)
include(./recipes/guile3.recipe.cmake)
include(./recipes/sagittarius.recipe.cmake)
include(./recipes/kawa.recipe.cmake)
include(./recipes/larceny.recipe.cmake)
include(./recipes/chez.recipe.cmake)
include(./recipes/gambit.recipe.cmake)
include(./recipes/picrin.recipe.cmake)
include(./recipes/mit-scheme.recipe.cmake)
include(./recipes/s7yuni.recipe.cmake)
include(./recipes/cyclone.recipe.cmake)
include(./recipes/scm.recipe.cmake)
include(./recipes/stklos.recipe.cmake)
include(./recipes/digamma.recipe.cmake)
include(./recipes/foment.recipe.cmake)
include(./recipes/bigloo.recipe.cmake)

# Source definitions
init_sources()
init_config_directory()
init_git_repositories() # Begin list-of repositories
include(${YUNIBASE_ROOT_STABLE}/sources.cmake)
include(./sources-current.cmake) # FIXME: somewhat inconsistent

register_source(YUNI CURRENT yuni GIT origin/master)
register_source(IMPL-STABLE CURRENT impl-stable GIT origin/master)

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
    activate_recipe(CHICKEN5 STABLE SKIP_TEST)
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
    activate_recipe(GUILE3 CURRENT IGNORE_TEST_FAILURE)
    activate_recipe(GAUCHE STABLE SKIP_TEST)
    activate_recipe(GAUCHE CURRENT ${allow_testfail_cygwin} ${skip_test_wsl})
    activate_recipe(CHIBI_SCHEME CURRENT)
    activate_recipe(RACKET STABLE)
    activate_recipe(RACKET CURRENT)
    activate_recipe(NMOSH STABLE IGNORE_TEST_FAILURE)
    activate_recipe(CHICKEN STABLE SKIP_TEST)
    activate_recipe(CHICKEN CURRENT SKIP_TEST)
    activate_recipe(CHICKEN5 STABLE SKIP_TEST)
    activate_recipe(CHICKEN5 CURRENT SKIP_TEST)
    if(${CMAKE_SYSTEM_PROCESSOR} MATCHES "i?86" AND
            ${CMAKE_SYSTEM_NAME} MATCHES "Linux")
        # Larceny currently only available on Linux/i386
        activate_recipe(LARCENY CURRENT)
    endif()
    activate_recipe(CHEZ CURRENT)
    activate_recipe(GAMBIT STABLE)
    activate_recipe(GAMBIT CURRENT)
    activate_recipe(PICRIN CURRENT)
    if(${CMAKE_SYSTEM_PROCESSOR} MATCHES "x86_64" AND
            (${CMAKE_SYSTEM_NAME} MATCHES "Linux" OR APPLE))
        activate_recipe(MIT_SCHEME STABLE)
        activate_recipe(MIT_SCHEME CURRENT)
    endif()
    activate_recipe(S7YUNI CURRENT)
    activate_recipe(CYCLONE STABLE)
    activate_recipe(CYCLONE CURRENT)
    activate_recipe(SCM STABLE)
    activate_recipe(STKLOS CURRENT)
    activate_recipe(DIGAMMA CURRENT)
    activate_recipe(FOMENT CURRENT)
    activate_recipe(BIGLOO STABLE)
    activate_recipe(BIGLOO CURRENT)
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

# Archive
set(secretfile ${CMAKE_CURRENT_BINARY_DIR}/secret.txt)

set(archive_tgts)
set(upload_tgts)

function(proc_archive impl branch sym)
    check_target_name(enabled ${sym})
    if(${branch} STREQUAL stable)
        set(arcbranch STABLE)
    else()
        set(arcbranch CURRENT)
    endif()
    if(enabled)
        set(tgta "archive-${impl}-${branch}")
        set(tgtu "upload-${impl}-${branch}")
        set(tag ${YUNIBASE_ARCHIVE_TAG})
        set(pkgname "yunibase_${tag}_${impl}_${branch}")
        set(archive "${YUNIBASE_ARCHIVE_OUTPUT_DIR}/${pkgname}.tar.gz")

        # Create archive target
        yunibase_artifact_archive(${tgta} ${impl} ${arcbranch} ${archive})
        if(YUNIBASE_BINTRAY_USERNAME)
            yunibase_artifact_upload(${tgtu} ${pkgname} ${archive} ${secretfile})
        endif()
        list(APPEND archive_tgts ${tgta})
        set(archive_tgts ${archive_tgts} PARENT_SCOPE)
        list(APPEND upload_tgts ${tgtu})
        set(upload_tgts ${upload_tgts} PARENT_SCOPE)

        add_dependencies(${tgta} all_${sym})
    endif()
endfunction()

if(YUNIBASE_ARCHIVE_TAG)
    if(NOT YUNIBASE_ARCHIVE_OUTPUT_DIR)
        set(YUNIBASE_ARCHIVE_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/archive")
    endif()
    file(MAKE_DIRECTORY ${YUNIBASE_ARCHIVE_OUTPUT_DIR})

    # Register impls
    ## R7RS
    proc_archive(chibi-scheme   current CHIBI_SCHEME_CURRENT)
    proc_archive(sagittarius    current SAGITTARIUS_CURRENT)
    proc_archive(sagittarius    stable  SAGITTARIUS_STABLE)
    proc_archive(larceny        current LARCENY_CURRENT)
    proc_archive(chicken        current CHICKEN_CURRENT)
    proc_archive(chicken        stable  CHICKEN_STABLE)
    proc_archive(chicken5       current CHICKEN5_CURRENT)
    proc_archive(chicken5       stable  CHICKEN5_STABLE)
    proc_archive(gauche         current GAUCHE_CURRENT)
    proc_archive(gauche         stable  GAUCHE_STABLE)
    proc_archive(kawa           current KAWA_CURRENT)
    proc_archive(picrin         current PICRIN_CURRENT)
    proc_archive(cyclone        stable  CYCLONE_STABLE)
    proc_archive(cyclone        current CYCLONE_CURRENT)
    proc_archive(digamma        current DIGAMMA_CURRENT)
    proc_archive(foment         current FOMENT_CURRENT)
    ## R6RS
    proc_archive(vicare         current VICARE_CURRENT)
    proc_archive(guile          current GUILE_CURRENT)
    proc_archive(guile3         current GUILE3_CURRENT)
    proc_archive(chez           current CHEZ_CURRENT)
    proc_archive(racket         stable  RACKET_STABLE)
    proc_archive(racket         current RACKET_CURRENT)
    ## R5RS
    proc_archive(bigloo         current BIGLOO_CURRENT)
    proc_archive(bigloo         stable  BIGLOO_STABLE)
    proc_archive(gambit         current GAMBIT_CURRENT)
    proc_archive(gambit         stable  GAMBIT_STABLE)
    proc_archive(mit-scheme     current MIT_SCHEME_CURRENT)
    proc_archive(mit-scheme     stable  MIT_SCHEME_STABLE)
    proc_archive(scm            stable  SCM_STABLE)
    proc_archive(stklos         current STKLOS_CURRENT)
    ## Generic
    proc_archive(s7yuni         current S7YUNI_CURRENT)


    add_custom_target(archive-all DEPENDS ${archive_tgts})
endif()

# Bintray

if(YUNIBASE_BINTRAY_USERNAME)
    if(NOT YUNIBASE_ARCHIVE_TAG)
        message(FATAL_ERROR "What are you going to upload?")
    endif()
    yunibase_artifact_gen_secretfile(${secretfile})
endif()

# License handling

function(register_impl sym nam)
    set(opts REQUIRE_STABLE REQUIRE_YUNI)
    set(oneargs "")
    set(multargs LICENSE_FILES)
    cmake_parse_arguments(arg "${opts}" "${oneargs}" 
        "${multargs}" ${ARGN})
    detect_source(srcpath ${sym} CURRENT)
    if(srcpath)
        foreach(f ${arg_LICENSE_FILES})
            set(pth ${srcpath}/${f})
            if(NOT EXISTS ${pth})
                message(FATAL_ERROR "${sym}: License file ${pth} not found.")
            endif()
            file(INSTALL ${pth} DESTINATION 
                ${YUNIBASE_BUILD_CURRENT_PREFIX}/${nam})
        endforeach()
    endif()
    detect_source(srcpath_stable ${sym} STABLE)
    if(srcpath_stable)
        foreach(f ${arg_LICENSE_FILES})
            set(pth ${srcpath_stable}/${f})
            if(NOT EXISTS ${pth})
                if(NOT STREQUAL RACKET)
                    # Racket has different source tree layout
                    # and we never redistribute stable racket
                    message(WARNING "${sym}: License file ${pth} not found.")
                endif()
            else()
                file(INSTALL ${pth} DESTINATION 
                    ${YUNIBASE_BUILD_STABLE_PREFIX}/${nam})
            endif()
        endforeach()
    endif()
endfunction()

# Prebuilt stable
if(YUNIBASE_PREBUILT_STABLE)
    file(MAKE_DIRECTORY ${YUNIBASE_BUILD_STABLE_PREFIX})
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar xvf ${YUNIBASE_PREBUILT_STABLE}
        WORKING_DIRECTORY ${YUNIBASE_BUILD_STABLE_PREFIX})
endif()

include(./parts/distrib.cmake)

if(YUNIBASE_FIX_TIMESTAMPS)
    # FIXME: Why do we need this here..? It can be more earlier..!
    if(NOT YUNIBASE_REPO_ROOT)
        set(YUNIBASE_REPO_ROOT ${CMAKE_CURRENT_LIST_DIR})
    endif()
    workaround_yunibase_impl_stable_timestamps()
endif()
