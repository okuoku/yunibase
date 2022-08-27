cmake_minimum_required(VERSION 3.0.0)
project(yunibasesingle NONE)

set(ROOT ${CMAKE_CURRENT_LIST_DIR}/..)

include(${ROOT}/cmake/YunibaseWorkaroundFileTimestamp.cmake)
set(YUNIBASE_REPO_ROOT ${ROOT})
workaround_yunibase_impl_stable_timestamps()
include(${ROOT}/config.cmake)

macro(register_impl sym nam)
    set(_lis ${ARGN})
    list(FIND _lis REQUIRE_STABLE qq)
    if(NOT ${qq} EQUAL -1)
        set(impl_${sym}_REQUIRE_STABLE ON)
    endif()
    list(FIND _lis REQUIRE_YUNI qq)
    if(NOT ${qq} EQUAL -1)
        set(impl_${sym}_REQUIRE_YUNI ON)
    endif()
    list(APPEND impls ${sym})
    set(impl_${sym}_name ${nam})
endmacro()

macro(impl_name var sym)
    if(impl_${sym}_name)
        set(${var} ${impl_${sym}_name})
    else()
        message(FATAL_ERROR "Unknown impl ${sym}.")
    endif()
endmacro()

include(${ROOT}/parts/distrib.cmake)

set(sourcesyms)
macro(register_source sym branch pth mode tag)
    if(${branch} STREQUAL DEP)
        # Dependencies
        get_filename_component(dirname ${pth} NAME)
        set(sourcesym ${sym}_DEP_${dirname})
        list(APPEND impl_${sym}_CURRENT_sourcesyms ${sourcesym})
    else()
        # STABLE or CURRENT
        set(sourcesym ${sym}_${branch})
        list(APPEND impl_${sym}_${branch}_sourcesyms ${sourcesym})
    endif()
    set(source_${sourcesym}_tagprotocol ${mode})
    set(source_${sourcesym}_tag ${tag})
    set(source_${sourcesym}_tagpath ${source_root}/${pth})
    list(APPEND sourcesyms ${sourcesym})
endmacro()

set(tree CURRENT)
set(source_root ${ROOT})
include(${ROOT}/sources-current.cmake)
set(source_root ${ROOT}/impl-stable)
set(tree STABLE)
include(${ROOT}/impl-stable/sources.cmake)

set(source_root ${ROOT})
register_source(yunisrc NONE yuni GIT "origin/master")

# Add source dependencies `source_<sourcesym>`
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/tags)
add_custom_target(check)
foreach(sym ${sourcesyms})
    add_custom_target(source_${sym}
        COMMAND
        ${CMAKE_COMMAND} 
        -DTAGPROTOCOL=${source_${sym}_tagprotocol}
        -DTAGPATH=${source_${sym}_tagpath}
        -DTAG=${source_${sym}_tag}
        -DDEST=${CMAKE_CURRENT_BINARY_DIR}/tags/${sym}.tag
        -P ${ROOT}/scripts/update-tagfile.cmake
        BYPRODUCTS ${CMAKE_CURRENT_BINARY_DIR}/tags/${sym}.tag
        )
    add_dependencies(check source_${sym})
endforeach()

if(CYGWIN)
    if(NOT YUNIBASE_WINDOWS_MODE)
        set(osname cygwin64)
    endif()
elseif(APPLE)
    # FIXME: Support Apple chips
    set(osname macosintel)
else()
    message(STATUS "???")
endif()

set(impls ${${osname}-impls})

if(NOT impls)
    message(FATAL_ERROR "Unknown OS...")
endif()

# Rsync impl-current and impl-stable 
foreach(d impl-current impl-stable)
    execute_process(
        COMMAND rsync -rltv --delete --exclude .git ${ROOT}/${d} 
        ${CMAKE_CURRENT_BINARY_DIR}
        RESULT_VARIABLE rr)

    if(rr)
        message(FATAL_ERROR "Failed to copy ${d}")
    endif()
endforeach()

# Generate build tree for each impls
add_custom_target(reset)
add_custom_target(allimpls ALL)
# Reset target
foreach(d impl-current impl-stable)
    add_custom_Target(reset-${d}
        COMMAND rsync -rltv --delete --exclude .git ${ROOT}/${d}
        ${CMAKE_CURRENT_BINARY_DIR})
    add_dependencies(reset reset-${d})
endforeach()

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/archives)
foreach(e ${impls})
    impl_name(nam ${e})
    set(builddir ${CMAKE_CURRENT_BINARY_DIR}/impl-${e})
    set(archive ${CMAKE_CURRENT_BINARY_DIR}/archives/${osname}-${nam}.tar.gz)
    # Calc source tree dependencies
    set(sourcedeps ${impl_${e}_CURRENT_sourcesyms})
    if(impl_${e}_REQUIRE_STABLE)
        list(APPEND sourcedeps ${impl_${e}_STABLE_sourcesyms})
    endif()
    if(impl_${e}_REQUIRE_YUNI)
        list(APPEND sourcedeps yunisrc_NONE)
    endif()
    set(tagfiles)
    foreach(s ${sourcedeps})
        message(STATUS "${e}: ${s}")
        list(APPEND tagfiles ${CMAKE_CURRENT_BINARY_DIR}/tags/${s}.tag)
    endforeach()

    # Generate build tree
    file(MAKE_DIRECTORY ${builddir})
    execute_process(
        COMMAND ${CMAKE_COMMAND}
        -DYUNIBASE_TARGET_PREFIX=/opt/yunibase
        -DYUNIBASE_ONLY=${e}
        -DYUNIBASE_ROOT_STABLE=${CMAKE_CURRENT_BINARY_DIR}/impl-stable
        -DYUNIBASE_ROOT_CURRENT=${CMAKE_CURRENT_BINARY_DIR}/impl-current
        -G${CMAKE_GENERATOR}
        ${CMAKE_CURRENT_LIST_DIR}/..
        OUTPUT_VARIABLE bogus
        WORKING_DIRECTORY ${builddir})

    # Build
    add_custom_command(
        OUTPUT ${archive}
        DEPENDS ${tagfiles}
        COMMAND ${CMAKE_COMMAND}
        -DDIR=${builddir}
        -DNAME=${nam}
        -DARCHIVE=${archive}
        -P ${ROOT}/scripts/buildstep.cmake)
    add_custom_target(build-${e}
        DEPENDS ${archive})
    add_dependencies(allimpls build-${e})
endforeach()

