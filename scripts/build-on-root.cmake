# Build yunibase tree on root (without Git updating)
#
# INPUTS:
#   USE_SYMLINK: Use symlink instead of copying
#   ONLY: List of impl.
#   EXCEPT: List of excluded impl.

set(_buildroot /build)
set(_mypath ${CMAKE_CURRENT_LIST_DIR})
get_filename_component(_mysrc ${_mypath}/.. ABSOLUTE)
get_filename_component(_mysrcroot ${_mysrc}/.. ABSOLUTE)
set(_myrootdir /yunisrc)
# FIXME: Abort on my directory != yunibase
set(_myroot /yunisrc/yunibase)

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

if(USE_SYMLINK)
    message(STATUS "Symlink ${_mysrc} => ${_myroot}")

    file(MAKE_DIRECTORY ${_myrootdir})
    execute_process(COMMAND
        ${CMAKE_COMMAND} -E create_symlink
        ${_mysrc} ${_myroot})
else()
    message(STATUS "Copying tree ${_mysrc} => ${_myroot}")

    file(COPY ${_mysrc} DESTINATION ${_myrootdir}
        PATTERN ".git" EXCLUDE)
endif()

message(STATUS "Configure(${_myroot})... ${_myargs}")

execute_process(COMMAND
    ${CMAKE_COMMAND} "${_onlyarg}" "${_exceptarg}" ${_myroot}
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
