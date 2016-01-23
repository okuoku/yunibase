
# 
# Generate Stamp file
#
# INPUTs:
#   ROOT = root path of the repository(full path)
#   OUTPUT = output base filename

message(STATUS "Query submodule refs...")
execute_process(COMMAND git submodule
    WORKING_DIRECTORY ${ROOT}
    OUTPUT_FILE ${OUTPUT}
    RESULT_VARIABLE rr)
if(rr)
    message(STATUS "Error. Removing ${OUTPUT}")
    file(REMOVE ${OUTPUT})
else()
    file(STRINGS ${OUTPUT} versions)
    foreach(e ${versions})
        message(STATUS "${e}")
    endforeach()
endif()

