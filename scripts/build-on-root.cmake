# Build yunibase tree on root (without Git updating)
#
# INPUTS:
#   BUILDROOT: 
#   INPLACE: Do not copy source tree at all
#   BOOTSTRAP_ONLY: YUNIBASE_BOOTSTRAP_ONLY
#   POSTBOOTSTRAP: YUNIBASE_POSTBOOTSTRAP
#   ONLY: List of impl.
#   EXCEPT: List of excluded impl.

if(BUILDROOT)
    set(_buildroot ${BUILDROOT})
else()
    set(_buildroot /build)
endif()

set(_mypath ${CMAKE_CURRENT_LIST_DIR})
get_filename_component(_mysrc ${_mypath}/.. ABSOLUTE)

if(INPLACE)
    set(_myroot ${_mysrc})
else()
    set(_myrootdir /yunisrc)
    # FIXME: Abort on my directory != yunibase
    set(_myroot /yunisrc/yunibase)
endif()

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
    message(STATUS "Copying tree ${_mysrc} => ${_myroot}")

    file(COPY ${_mysrc} DESTINATION ${_myrootdir}
        PATTERN ".git" EXCLUDE)
endif()

message(STATUS "Configure(${_myroot})... ${_myargs}")

execute_process(COMMAND
    ${CMAKE_COMMAND} "${_onlyarg}" "${_exceptarg}" 
    "${_bootstraparg}"
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

message(STATUS "Done.")
