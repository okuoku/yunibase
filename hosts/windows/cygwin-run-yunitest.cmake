# yunitest on cygwin
#
# INPUTs:
#  YUNI: Path to yuni repository

if(NOT YUNI)
    message(FATAL_ERROR "YUNI argument is required")
endif()

set(_pth ${YUNI}/integration/buildhost-yunibase/test-on-root.cmake)

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

# Launch builder
execute_process(
    COMMAND cyg64/bin/bash -l -c
    "cmake -P ${out}"
    )

