#
# update-tagfile.cmake
#
# INPUTs:
#   TAGPROTOCOL: GIT | STATIC
#   TAG: commit hash(GIT) or string(STATIC)
#   TAGPATH: Path to tag source(GIT)
#   DEST: Full path to destination file(update target)

set(sayinfo OFF)
set(revstat "rev = UNKNOWN")

function(diag)
    message(STATUS "TAGPROTOCOL: ${TAGPROTOCOL}")
    message(STATUS "TAGPATH: ${TAGPATH}")
    message(STATUS "TAG: ${TAG} (ignored for GIT)")
    message(STATUS "${revstat}")
endfunction()

if(${TAGPROTOCOL} STREQUAL GIT)
    execute_process(COMMAND git rev-parse HEAD
        WORKING_DIRECTORY ${TAGPATH}
        OUTPUT_VARIABLE rev
        RESULT_VARIABLE rr)
    if(rr)
        diag()
        message(FATAL_ERROR "Err (${rr}")
    endif()
    string(STRIP ${rev} rev)
else()
    set(rev ${TAG})
endif()

if(EXISTS ${DEST})
    file(STRINGS ${DEST} old_rev)
    if(${old_rev} STREQUAL ${rev})
        #message(STATUS "REV = ${rev} (unchanged)")
    else()
        set(sayinfo ON)
        set(revstat "REV = ${rev} (update)")
        file(WRITE ${DEST} "${rev}")
    endif()
else()
    set(sayinfo ON)
    set(revstat "REV = ${rev} (new file)")
    file(WRITE ${DEST} "${rev}")
endif()

if(sayinfo)
    diag()
endif()
