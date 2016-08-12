#
# Run build-on-root.cmake on docker image
#
# INPUTs:
#   IMAGE: base image
#   TAG: Docker image tag
#   ONLY: ONLY
#   EXCEPT: EXCEPT
#   CIDFILE: absolute path to cidfile (will be removed/replaced)

if(NOT CIDFILE)
    message(FATAL_ERROR "CIDFILE?")
endif()
if(NOT IMAGE)
    message(FATAL_ERROR "IMAGE?")
endif()
if(NOT TAG)
    message(FATAL_ERROR "TAG?")
endif()

if(ONLY)
    set(_onlyarg "-DONLY=${ONLY}")
else()
    set(_onlyarg "")
endif()

if(EXCEPT)
    set(_exceptarg "-DEXCEPT=${EXCEPT}")
else()
    set(_exceptarg "")
endif()

set(_mypath ${CMAKE_CURRENT_LIST_DIR})
get_filename_component(_mysrc ${_mypath}/../.. ABSOLUTE)

file(REMOVE ${CIDFILE})

message(STATUS "build(${IMAGE})...")

# Launch build process
execute_process(
    COMMAND docker run
    --cidfile=${CIDFILE}
    -it
    -v ${_mysrc}:/yunibase.build:Z
    ${IMAGE}
    cmake "${_onlyarg}" "${_exceptarg}"
    -DCLEANSOURCES=TRUE
    -DYUNIBASEROOT=/yunibase
    -P /yunibase.build/scripts/build-on-root.cmake
    RESULT_VARIABLE rr)

if(rr)
    # Remove CIDFILE
    file(REMOVE ${CIDFILE})
    # Bailout
    message(FATAL_ERROR "Failed to build yunibase")
endif()

# Commit image
file(READ ${CIDFILE} _cid)

message(STATUS "Commit image...${_cid}")

execute_process(
    COMMAND docker commit -m "Yunibase build"
    ${_cid} ${TAG}
    RESULT_VARIABLE rr)

if(rr)
    # Remove CIDFILE
    file(REMOVE ${CIDFILE})
    # Bailout
    message(FATAL_ERROR "Failed to commit image")
endif()

message(STATUS "Removing intermediate container(${_cid})")

# Remove container
execute_process(
    COMMAND docker rm ${_cid}
    RESULT_VARIABLE rr)

if(rr)
    message(STATUS "Warning: Failed to remove container ${rr}")
endif()

# Remove CIDFILE
file(REMOVE ${CIDFILE})

message(STATUS "Done(${IMAGE} => ${TAG}).")

