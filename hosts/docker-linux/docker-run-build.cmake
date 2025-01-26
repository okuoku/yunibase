#
# Run build-on-root.cmake on docker image
#
# INPUTs:
#   BUILDYUNI: Install yuni library instead 
#   IMAGE: base image
#   TAG: Docker image tag
#   ONLY: ONLY
#   EXCEPT: EXCEPT
#   STAMP: Stamp file
#   CIDFILE: absolute path to cidfile (will be removed/replaced)
#   LOGFILE: absolute path to logfile
#   ARCHIVEDIR: absolute path to archive output dir
#   ARCHIVEPREFIX: prefix for archive

if(BUILDYUNI)
    set(_myname "yuniimage")
else()
    set(_myname "yunibase")
endif()

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

if(STAMP)
    file(STRINGS ${STAMP} versions)
    unset(stamp_version)
    foreach(e ${versions})
        if(NOT stamp_version)
            set(stamp_version "${e}")
        endif()
    endforeach()
endif()

if(stamp_version)
    set(_labelarg -c "LABEL org.label-schema.vcs-ref=${stamp_version} org.label-schema.vcs-url=https://github.com/okuoku/yunibase")
else()
    set(_labelarg "")
endif()

set(_mypath ${CMAKE_CURRENT_LIST_DIR})
get_filename_component(_mysrc ${_mypath}/../.. ABSOLUTE)

file(REMOVE ${CIDFILE})

# Detect if the docker is actually a podman
execute_process(
    COMMAND docker -v
    OUTPUT_VARIABLE out
    RESULT_VARIABLE rr)
if(rr)
    message(STATUS "Failed to execute docker executable (${rr})")
endif()
if(${out} MATCHES "^podman")
    message(STATUS "Using podman docker emulation")
    set(USE_PODMAN ON)
else()
    set(USE_PODMAN OFF)
endif()

message(STATUS "build(${IMAGE})...")

# Launch build process
if(BUILDYUNI)
    # Build yuni image(Yuni libraries and native components)
    execute_process(
        COMMAND docker run
        --cidfile=${CIDFILE}
        -i
        -v ${_mysrc}:/yunibase.build:Z
        ${IMAGE}
        cmake "${_onlyarg}" "${_exceptarg}"
        -DCLEAN=TRUE
        -DVERBOSE=TRUE
        -DSKIP_LONGRUN=TRUE
        -P 
        /yunibase.build/yuni/integration/buildhost-yunibase/test-on-root.cmake
        OUTPUT_FILE ${LOGFILE}
        ERROR_FILE ${LOGFILE}
        RESULT_VARIABLE rr)
else()
    # Build yunibase image(Scheme implementations)
    execute_process(
        COMMAND docker run
        --cidfile=${CIDFILE}
        -i
        -v ${ARCHIVEDIR}:/yunibase.archive
        -v ${_mysrc}:/yunibase.build:Z
        ${IMAGE}
        cmake "${_onlyarg}" "${_exceptarg}"
        -DYUNIBASEROOT=/opt/yunibase
        -DARCHIVEDIR=/yunibase.archive
        -DARCHIVEPREFIX=${ARCHIVEPREFIX}
        -P /yunibase.build/scripts/deploy-archives.cmake
        OUTPUT_FILE ${LOGFILE}
        ERROR_FILE ${LOGFILE}
        RESULT_VARIABLE rr)
endif()

if(rr)
    # Remove CIDFILE
    file(REMOVE ${CIDFILE})
    # Bailout
    message(FATAL_ERROR "Failed to build ${IMAGE}(${_myname})")
endif()

# Commit image
file(READ ${CIDFILE} _cid)

message(STATUS "Commit image...${_cid}")
if(stamp_version)
    message(STATUS "Stamp version = ${stamp_version}")
endif()

if(USE_PODMAN)
    set(commit_opts -f docker)
else()
    set(commot_opts -m "${_myname} build")
endif()

execute_process(
    COMMAND docker commit ${commit_opts}
    ${_labelarg}
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

