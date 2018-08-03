#
# Deploy yunibase archive to /opt/yunibase
#
# INPUTs:
#   ARCHIVE: Full path to archive
#   IMPLNAM: Implementation dir name

if(NOT IMPLNAM)
    message(FATAL_ERROR "Huh?")
endif()
if(NOT ARCHIVE)
    message(FATAL_ERROR "Huh?")
endif()

if(NOT EXISTS ${ARCHIVE})
    message(STATUS "File ${ARCHIVE} not found (Skip)")
    return()
endif()
set(destdir /opt/yunibase/current/${IMPLNAM})

if(EXISTS ${destdir})
    file(REMOVE_RECURSE ${destdir})
endif()

file(MAKE_DIRECTORY /opt/yunibase/current)

execute_process(
    COMMAND tar zxf ${ARCHIVE}
    WORKING_DIRECTORY /opt/yunibase/current)

