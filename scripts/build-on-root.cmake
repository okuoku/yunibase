# Build yunibase tree on root (without Git updating)
#
# INPUTS:
#   CLEANSOURCES: remove copied sources
#   BUILDROOT: 
#   SRCROOT:
#   INPLACE: Do not copy source tree at all
#   BOOTSTRAP_ONLY: YUNIBASE_BOOTSTRAP_ONLY
#   POSTBOOTSTRAP: YUNIBASE_POSTBOOTSTRAP
#   ONLY: List of impl.
#   EXCEPT: List of excluded impl.
#   USE_GMAKE: YUNIBASE_USE_GMAKE
#   ALTPREFIX: Setup Envvar LDFLAGS and CPPFLAGS for ALTPREFIX

if(CLEANSOURCES AND INPLACE)
    message(FATAL_ERROR "Why?")
endif()

if(CLEANSOURCES AND SRCROOT)
    message(FATAL_ERROR "Why?")
endif()

if(INPLACE AND SRCROOT)
    message(FATAL_ERROR "Why?")
endif()

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
    set(srcdir_${nam}_${flav} ${register_src_listpath}/${pth})
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
    ${_mysrc}/recipes
    ${_mysrc}/scripts)

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

if(INPLACE)
    message(STATUS "Using existing yunibase ${_myroot}")
else()
    setup_sources()
endif()

message(STATUS "Configure(${_myroot})... ${_myargs}")

execute_process(COMMAND
    ${CMAKE_COMMAND} "${_onlyarg}" "${_exceptarg}" 
    "${_bootstraparg}"
    "${_usegmakearg}"
    ${_myroot}
    RESULT_VARIABLE rr
    WORKING_DIRECTORY ${_buildroot}
)
if(rr)
    message(FATAL_ERROR "Faild to configure tree")
endif()

message(STATUS "Building...")

execute_process(COMMAND
    ${CMAKE_COMMAND} --build .
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

message(STATUS "Done.")
