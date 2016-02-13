# Build on cygwin
#
# INPUTs:
#    ONLY: ONLY

if(NOT ONLY)
    message(FATAL_ERROR "ONLY argument is required")
endif()

macro(escape_args var first)
    set(${var} "${first}")
    foreach(e ${ARGN})
        set(${var} "${${var}}\\;${e}")
    endforeach()
endmacro()

set(_pth ${CMAKE_CURRENT_LIST_DIR}/../../scripts/build-on-root.cmake)

# First, translate filepath into cygpath
execute_process(
    COMMAND cygpath ${_pth}
    WORKING_DIRECTORY cyg64/bin
    OUTPUT_VARIABLE out
    RESULT_VARIABLE rr)

if(rr)
    message(FATAL_ERROR "Cannot translate script path ${rr}")
endif()

message(STATUS "Script path = ${out}")

escape_args(_onlyargs ${ONLY})
# Launch builder
execute_process(
    COMMAND cyg64/bin/bash -l -c
    "cmake \"-DONLY=${_onlyargs}\" -P ${out}"
    )

