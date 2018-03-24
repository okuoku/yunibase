#
# update-tagfile.cmake
#
# INPUTs:
#   TAGPROTOCOL: GIT | STATIC
#   TAG: commit hash(GIT) or string(STATIC)
#   TAGPATH: Path to tag source(GIT)
#   DEST: Full path to destination file(update target)

message(STATUS "TAGPROTOCOL: ${TAGPROTOCOL}")
message(STATUS "TAGPATH: ${TAGPATH}")
message(STATUS "TAG: ${TAG} (ignored for GIT)")

if(${TAGPROTOCOL} STREQUAL GIT)
    execute_process(COMMAND git rev-parse HEAD
        WORKING_DIRECTORY ${TAGPATH}
        OUTPUT_VARIABLE rev
        RESULT_VARIABLE rr)
    if(rr)
        message(FATAL_ERROR "Err (${rr}")
    endif()
    string(STRIP ${rev} rev)
else()
    set(rev ${TAG})
endif()

if(EXISTS ${DEST})
    file(STRINGS ${DEST} old_rev)
    if(${old_rev} STREQUAL ${rev})
        message(STATUS "REV = ${rev} (unchanged)")
        file(WRITE ${DEST} "${rev}")
    else()
        message(STATUS "REV = ${rev} (update)")
        file(WRITE ${DEST} "${rev}")
    endif()
else()
    message(STATUS "REV = ${rev} (new file)")
    file(WRITE ${DEST} "${rev}")
endif()

