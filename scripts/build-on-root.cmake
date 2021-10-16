# Build yunibase tree on root (without Git updating)
#
# INPUTS:
#   CLEANSOURCES: remove copied sources
#   CLEANBUILDROOT: remove build working dirs
#   BUILDROOT: 
#   SRCROOT:
#   YUNIBASEROOT: YUNIBASE_TARGET_PREFIX
#   INPLACE: Do not copy source tree at all
#   BOOTSTRAP_ONLY: YUNIBASE_BOOTSTRAP_ONLY
#   POSTBOOTSTRAP: YUNIBASE_POSTBOOTSTRAP
#   ONLY: List of impl.
#   EXCEPT: List of excluded impl.
#   USE_GMAKE: YUNIBASE_USE_GMAKE
#   ALTPREFIX: Setup Envvar LDFLAGS and CPPFLAGS for ALTPREFIX
#   PREBUILT_STABLE: YUNIBASE_PREBUILT_STABLE
#   BUILDTARGET: Target to run
#   ARCHIVE_TAG: YUNIBASE_ARCHIVE_TAG
#   ARCHIVE_OUTPUT_DIR: YUNIBASE_ARCHIVE_OUTPUT_DIR

if(CLEANSOURCES AND INPLACE)
    message(FATAL_ERROR "Why?")
endif()

if(CLEANSOURCES AND SRCROOT)
    message(FATAL_ERROR "Why?")
endif()

if(INPLACE AND SRCROOT)
    message(FATAL_ERROR "Why?")
endif()

macro(split_atlist0 var reg rest)
    if(${rest} MATCHES "([^@]*)@(.*)")
        message(STATUS "SPLIT(${var}): ${CMAKE_MATCH_1}")
        split_atlist0(${var} "${reg};${CMAKE_MATCH_1}" ${CMAKE_MATCH_2})
    else()
        set(${var} ${reg} ${rest})
        message(STATUS "SPLIT_RESULT: ${var} = ${${var}}")
    endif()
endmacro()

macro(split_atlist var)
    if(${var} MATCHES "([^@]*)@(.*)")
        message(STATUS "SPLIT(${var}): ${CMAKE_MATCH_1}")
        split_atlist0(${var} ${CMAKE_MATCH_1} ${CMAKE_MATCH_2})
    endif()
endmacro()

split_atlist(ONLY)
split_atlist(EXCEPT)

if(ALTPREFIX)
    set(ENV{LDFLAGS} "-L${ALTPREFIX}/lib")
    set(ENV{CPPFLAGS} "-I${ALTPREFIX}/include")
endif()

set(_mypath ${CMAKE_CURRENT_LIST_DIR})
get_filename_component(_mysrc ${_mypath}/.. ABSOLUTE)

if(INPLACE)
    set(_myroot ${_mysrc})
elseif(SRCROOT)
    set(_myroot ${SRCROOT})
else()
    set(_myroot /yunisrc/yunibase)
endif()

set(impls)
set(srcdirs)

macro(register_source nam flav pth rcstype rcspath)
    if(NOT have_${nam})
        list(APPEND impls ${nam})
        set(have_${nam} TRUE)
    endif()
    # RELATIVE path for sources
    if(${flav} STREQUAL DEP)
        # Dependencies
        list(APPEND srcdir_${nam}_${flav} ${pth})
    else()
        if(srcdir_${nam}_${flav})
            message(FATAL_ERROR "Already registered: ${nam} ${flav} ${srcdir_${nam}_${flav}}")
        endif()
        # Main source (CURRENT/STABLE)
        set(srcdir_${nam}_${flav} ${register_src_listpath}/${pth})
    endif()
endmacro()

if(BUILDROOT)
    set(_buildroot ${BUILDROOT})
else()
    set(_buildroot /build)
endif()

# Register source paths
set(basefiles
    ${_mysrc}/CMakeLists.txt
    ${_mysrc}/sources-current.cmake)

set(basedirs
    ${_mysrc}/cmake
    ${_mysrc}/hosts
    ${_mysrc}/parts
    ${_mysrc}/overrides
    ${_mysrc}/recipes
    ${_mysrc}/scripts
    ${_mysrc}/yuni)

set(register_src_listpath .)
include(${_mysrc}/sources-current.cmake)
set(register_src_listpath ./impl-stable)
include(${_mysrc}/impl-stable/sources.cmake)

function(setup_sources)
    message(STATUS "Copying tree ${_mysrc} => ${_myroot}")
    file(MAKE_DIRECTORY ${_myroot})
    file(MAKE_DIRECTORY ${_myroot}/impl-stable)
    file(MAKE_DIRECTORY ${_myroot}/impl-current)

    # basefiles
    file(COPY ${basefiles} DESTINATION ${_myroot})

    file(COPY ${_mysrc}/impl-stable/sources.cmake 
        DESTINATION
        ${_myroot}/impl-stable)

    file(COPY ${basedirs} DESTINATION ${_myroot}
        PATTERN ".git" EXCLUDE)

    # Sources
    if(ONLY)
        # Override impls
        set(impls ${ONLY})
    endif()
    if(EXCEPT)
        # Remove entries from impls
        list(REMOVE_ITEM impls ${EXCEPT})
    endif()
    foreach(e ${impls})
        foreach(flav STABLE CURRENT)
            if(srcdir_${e}_${flav})
                # FIXME: Uncool
                if(${flav} STREQUAL STABLE)
                    set(_dest ${_myroot}/impl-stable)
                else()
                    set(_dest ${_myroot}/impl-current)
                endif()
                message(STATUS "COPYING: ${e} ${flav} => ${_dest}")
                file(COPY ${_mysrc}/${srcdir_${e}_${flav}}
                    DESTINATION ${_dest}
                    PATTERN ".git" EXCLUDE)
            endif()
        endforeach()
        if(srcdir_${e}_DEP)
            foreach(src ${srcdir_${e}_DEP})
                set(_dest ${_myroot}/impl-current)
                # FIXME: Uncool
                string(REGEX REPLACE "([^/]+)/([^/]+).*" "\\2" srcdir ${src})
                message(STATUS "COPYING ${e} DEP: ${src} => ${_dest}/${srcdir}")
                file(COPY ${_mysrc}/${src}
                    DESTINATION ${_dest}/${srcdir}
                    PATTERN ".git" EXCLUDE)
            endforeach()
        endif()
    endforeach()
endfunction()


file(MAKE_DIRECTORY ${_buildroot})

if(ONLY)
    set(_onlyarg "-DYUNIBASE_ONLY=${ONLY}")
else()
    set(_onlyarg)
endif()

if(EXCEPT)
    set(_exceptarg "-DYUNIBASE_EXCEPT=${EXCEPT}")
else()
    set(_exceptarg)
endif()

if(USE_GMAKE)
    set(_usegmakearg "-DYUNIBASE_USE_GMAKE=TRUE")
else()
    set(_usegmakearg "")
endif()

if(BOOTSTRAP_ONLY AND POSTBOOTSTRAP)
    message(FATAL_ERROR "Nothing to do.")
endif()

if(BOOTSTRAP_ONLY)
    set(_bootstraparg "-DYUNIBASE_BOOTSTRAP_ONLY=TRUE")
elseif(POSTBOOTSTRAP)
    set(_bootstraparg "-DYUNIBASE_POSTBOOTSTRAP=TRUE")
else()
    set(_bootstraparg)
endif()

if(YUNIBASEROOT)
    set(_yunibaseroot "-DYUNIBASE_TARGET_PREFIX=${YUNIBASEROOT}")
else()
    set(_yunibaseroot "")
endif()

if(INPLACE)
    message(STATUS "Using existing yunibase ${_myroot}")
else()
    setup_sources()
endif()

if(PREBUILT_STABLE)
    set(_prebuilt_stablearg "-DYUNIBASE_PREBUILT_STABLE=${PREBUILT_STABLE}")
else()
    set(_prebuilt_stablearg)
endif()

if(ARCHIVE_TAG)
    set(_archive_tagarg "-DYUNIBASE_ARCHIVE_TAG=${ARCHIVE_TAG}")
else()
    set(_archive_tagarg)
endif()

if(ARCHIVE_OUTPUT_DIR)
    set(_archive_output_dirarg 
        "-DYUNIBASE_ARCHIVE_OUTPUT_DIR=${ARCHIVE_OUTPUT_DIR}")
else()
    set(_archive_output_dirarg)
endif()


message(STATUS "Configure(${_myroot})... ${_myargs}")

execute_process(COMMAND
    ${CMAKE_COMMAND} "${_onlyarg}" "${_exceptarg}" 
    "${_bootstraparg}"
    "${_usegmakearg}"
    "${_prebuilt_stablearg}"
    "${_yunibaseroot}"
    ${_archive_tagarg}
    ${_archive_output_dirarg}
    ${_myroot}
    RESULT_VARIABLE rr
    WORKING_DIRECTORY ${_buildroot}
)
if(rr)
    message(FATAL_ERROR "Faild to configure tree")
endif()

if(BUILDTARGET)
    message(STATUS "Building(${BUILDTARGET})...")
    set(_buildtarget --target ${BUILDTARGET})
else()
    message(STATUS "Building...")
    set(_buildtarget)
endif()


execute_process(COMMAND
    ${CMAKE_COMMAND} --build .
    ${_buildtarget}
    RESULT_VARIABLE rr
    WORKING_DIRECTORY ${_buildroot})

if(rr)
    message(FATAL_ERROR "Faild to build tree")
endif()

if(CLEANSOURCES AND NOT INPLACE)
    if(EXISTS /yunisrc)
        message(STATUS "Removing source tree...")
        execute_process(COMMAND
            ${CMAKE_COMMAND} -E remove_directory /yunisrc)
    endif()
endif()

if(CLEANBUILDROOT AND NOT INPLACE)
    if(EXISTS ${BUILDROOT})
        message(STATUS "Removing builddir...")
        execute_process(COMMAND
            ${CMAKE_COMMAND} -E remove_directory ${BUILDROOT})
    endif()
endif()

message(STATUS "Done.")
