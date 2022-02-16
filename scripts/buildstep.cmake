if(NOT DIR) # Impl builddir 
    message(FATAL_ERROR "huh?")
endif()

if(NOT NAME) # Impl CMake name "chibi-scheme"
    message(FATAL_ERROR "huh?")
endif()

if(NOT ARCHIVE) # CMake path for archive
    message(FATAL_ERROR "huh?")
endif()

# Remove existing impl.
message(STATUS "Cleanup...${NAME}")
execute_process(
    COMMAND ${CMAKE_COMMAND} -E remove_directory
    /opt/yunibase/stable/${NAME})
execute_process(
    COMMAND ${CMAKE_COMMAND} -E remove_directory
    /opt/yunibase/current/${NAME})

# Build
message(STATUS "Build...${NAME}")
execute_process(
    COMMAND ${CMAKE_COMMAND} --build ${DIR}
    RESULT_VARIABLE rr)

if(rr)
    message(FATAL_ERROR "Error build ${NAME}")
endif()

# Generate archive
message(STATUS "Archive...${NAME}")
execute_process(
    COMMAND tar cvzf ${ARCHIVE}
    ${NAME}
    WORKING_DIRECTORY /opt/yunibase/current
    RESULT_VARIABLE rr)

if(rr)
    message(FATAL_ERROR "Error archive ${NAME}")
endif()

