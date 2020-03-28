#
# Deploy yunibase archive to /opt/yunibase
#
# INPUTs:
#   ARCHIVE: Full path to archive
#   IMPLNAM: Implementation dir name
#   BRANCH: current/stable

if(NOT BRANCH)
    set(BRANCH current)
elseif(${BRANCH} STREQUAL CURRENT)
    set(BRANCH current)
elseif(${BRANCH} STREQUAL STABLE)
    set(BRANCH stable)
else()
    message(FATAL_ERROR "Unknown branch name: ${BRANCH}")
endif()

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
set(destdir /opt/yunibase/${BRANCH}/${IMPLNAM})

if(EXISTS ${destdir})
    file(REMOVE_RECURSE ${destdir})
endif()

file(MAKE_DIRECTORY /opt/yunibase/${BRANCH})

execute_process(
    COMMAND tar zxf ${ARCHIVE}
    WORKING_DIRECTORY /opt/yunibase/${BRANCH})

