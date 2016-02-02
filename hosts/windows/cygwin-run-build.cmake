# First, translate filepath into cygpath

set(_pth ${CMAKE_CURRENT_LIST_DIR}/../../scripts/build-on-root.cmake)

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
    "cmake -DEXCEPT=CHIBI_SCHEME\;CHICKEN\;GUILE\;RACKET\;VICARE -P ${out}"
    )

