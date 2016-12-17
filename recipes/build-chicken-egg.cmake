#
# Chicken-egg build helper
#
# INPUT:
#  SRC: Absolute path to egg directory
#

execute_process(
    COMMAND chicken-install
    RESULT_VARIABLE rr
    WORKING_DIRECTORY ${SRC})

if(rr)
    message(FATAL_ERROR "Error: (${rr})")
endif()
