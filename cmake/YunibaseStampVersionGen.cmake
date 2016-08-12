
# 
# Generate Stamp file
#
# INPUTs:
#   ROOT = root path of the repository(full path)
#   OUTPUT = output base filename

message(STATUS "My rev...")
execute_process(COMMAND git rev-parse HEAD
    WORKING_DIRECTORY ${ROOT}
    OUTPUT_VARIABLE myrev
    RESULT_VARIABLE rr)
if(rr)
    message(STATUS "Error(${rr}).")
    return()
endif()
message(STATUS "${myrev}")
message(STATUS "Query submodule refs...")
execute_process(COMMAND git submodule
    WORKING_DIRECTORY ${ROOT}
    OUTPUT_VARIABLE subrev
    RESULT_VARIABLE rr)
if(rr)
    message(STATUS "Error(${rr}).")
else()
    file(WRITE ${OUTPUT} "${myrev}")
    file(APPEND ${OUTPUT} "${subrev}")
    file(STRINGS ${OUTPUT} versions)
    foreach(e ${versions})
        message(STATUS "${e}")
    endforeach()
endif()

