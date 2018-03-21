#
# Run build-on-root.cmake on docker image to build archive
#
# INPUTs:
#   IMAGE: base image
#   LOGFILE: absolute path to logfile
#   PREBUILT_STABLE: relative path to prebuilt archive (optional)
#   ARCHIVEDIR: absolute path to archive output dir
#   ARCHIVEPREFIX: prefix for archive
#   TARGET: BUILDTARGET
#   ONLY: IMPL name

if(NOT IMAGE)
    message(FATAL_ERROR "IMAGE?")
endif()

set(_mypath ${CMAKE_CURRENT_LIST_DIR})
get_filename_component(_mysrc ${_mypath}/../.. ABSOLUTE)

if(PREBUILT_STABLE)
    set(_prebuilt_stablearg
        -DPREBUILT_STABLE=/yunibase.archive/${PREBUILT_STABLE})
else()
    set(_prebuilt_stablearg)
endif()

# Build archive
execute_process(
    COMMAND docker run
    --rm
    -i
    -v ${ARCHIVEDIR}:/yunibase.archive:Z
    -v ${_mysrc}:/yunibase.build:Z
    ${IMAGE}
    cmake 
    -DYUNIBASEROOT=/opt/yunibase
    -DBUILDTARGET=${TARGET}
    -DARCHIVE_OUTPUT_DIR=/yunibase.archive
    -DARCHIVE_TAG=${ARCHIVEPREFIX}
    -DONLY=${ONLY}
    ${_prebuilt_stablearg}
    -P /yunibase.build/scripts/build-on-root.cmake
    OUTPUT_FILE ${LOGFILE}
    ERROR_FILE ${LOGFILE}
    RESULT_VARIABLE rr)

if(rr)
    # Bailout
    message(FATAL_ERROR "Failed to build ${TARGET} with ${IMAGE}")
endif()

message(STATUS "Done(${TARGET} with ${IMAGE}).")

