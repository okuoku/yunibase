# Bootstrap in Cygwin, build in MSYS
#
# INPUTs:
#   ONLY: ONLY

# In msys64:
#
#   [msys64]/yunisrc/yunibase.win32
#   [msys64]/yunisrc/yunibase.win64
#   [msys64]/build.cygwinboot - Bootstrap
#   [msys64]/build.msys

if(NOT ONLY)
    message(FATAL_ERROR "ONLY argument is required")
endif()

set(_pth ${CMAKE_CURRENT_LIST_DIR}/../../scripts/build-on-root.cmake)

# First, translate filepath into cygpath
execute_process(
    COMMAND cygpath ${_pth}
    WORKING_DIRECTORY cyg64/bin
    OUTPUT_VARIABLE _buildonroot
    RESULT_VARIABLE rr)

if(rr)
    message(FATAL_ERROR "Cannot translate script path ${rr}")
endif()

message(STATUS "Script path = ${out}")


macro(escape_args var first)
    set(${var} "${first}")
    foreach(e ${ARGN})
        set(${var} "${${var}}\\;${e}")
    endforeach()
endmacro()

# Convert msys directory into cygwin path
set(_mydir ${CMAKE_CURRENT_LIST_DIR})
get_filename_component(_mysrc ${_mydir}/../.. ABSOLUTE)
execute_process(
    # -a is for absolute
    COMMAND cygpath -a ${CMAKE_CURRENT_BINARY_DIR}/msys64
    WORKING_DIRECTORY cyg64/bin
    OUTPUT_STRIP_TRAILING_WHITESPACE
    OUTPUT_VARIABLE out
    RESULT_VARIABLE rr)

if(rr)
    message(FATAL_ERROR "Cannot translate MSYS rootpath ${rr}")
endif()

set(_msysloc ${out})

message(STATUS "Location(cygwin): [${_msysloc}]")


# Construct directories
function(construct_tree sufx)
    message(STATUS "Generating source tree(${sufx})")
    escape_args(_onlyargs ${ONLY})

    # Bootstrap on Cygwin
    execute_process(
        COMMAND cyg64/bin/bash -l -c
        "cmake \"-DONLY=${_onlyargs}\" -DBOOTSTRAP_ONLY=TRUE -DSRCROOT=${_msysloc}/yunisrc/yunibase.${sufx} -DBUILDROOT=/build.cygwinboot-${sufx} -P ${_buildonroot}"
        RESULT_VARIABLE rr)
    if(rr)
        message(FATAL_ERROR "Failed to construct bootstrap tree ${sufx}")
    endif()
endfunction()

construct_tree(win32)
construct_tree(win64)

# Build trees

