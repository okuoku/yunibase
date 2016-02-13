# 
# Fetch ssh configuration for running vagrant VM
#
# INPUTs:
#   PATH: Path to directory containing .vagrant
#   OUT: Output file path

execute_process(
    COMMAND vagrant ssh-config
    OUTPUT_FILE ${OUT}
    RESULT_VARIABLE rr
    WORKING_DIRECTORY ${PATH})

if(rr)
    message(FATAL_ERROR "Error ${rr}")
endif()
