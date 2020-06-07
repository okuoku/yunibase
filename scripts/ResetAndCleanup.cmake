message(STATUS "Reset...")
execute_process(
    COMMAND git submodule foreach --recursive git reset --hard
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/..
    )
message(STATUS "Cleanup...")
execute_process(
    COMMAND git submodule foreach --recursive git clean -xfd .
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/..
    )
message(STATUS "Sync URLs...")
execute_process(
    COMMAND git submodule sync --recursive
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/..
    )
message(STATUS "Checkout...")
execute_process(
    COMMAND git submodule update --recursive
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/..
    )
