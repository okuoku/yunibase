cmake_minimum_required(VERSION 2.8)
project(yunibuild-docker-linux NONE)

set(YUNIBASE_REPO_ROOT ${CMAKE_CURRENT_LIST_DIR}/../../)
list(APPEND CMAKE_MODULE_PATH ${YUNIBASE_REPO_ROOT}/cmake)

include(YunibaseStampVersion)

add_custom_target(base)   # Update base environment
add_custom_target(sync)   # Update Scheme implementations
add_custom_target(image)  # Build yunibase images (without yuni)
add_custom_target(yuniimage) # Install yuni on yunibase images
add_custom_target(taste)  # Check latest sources
add_custom_target(push)   # Push built images
add_custom_target(stamp)  # Stamp current repository version
add_custom_target(yunitest) # Test with ${YUNIBASE_WITH_YUNI}

# Globals
set(YUNIBASE_MASTER_REMOTE "none" 
    CACHE STRING "Master Git local name to sync with")

if(NOT ${YUNIBASE_MASTER_REMOTE} STREQUAL "none")
    add_custom_target(try-master-sync
        COMMAND git fetch ${YUNIBASE_MASTER_REMOTE}
        COMMAND git reset --hard ${YUNIBASE_MASTER_REMOTE}/master
        COMMAND git submodule update --init --recursive
        WORKING_DIRECTORY ${YUNIBASE_REPO_ROOT}
        )
endif()


# Paths
set(BUILDCTX_NONE 
    "${YUNIBASE_REPO_ROOT}/hosts/docker-linux")
set(BASE_FEDORA 
    "${YUNIBASE_REPO_ROOT}/hosts/docker-linux/base-fedora/Dockerfile")
set(BASE_ALPINE
    "${YUNIBASE_REPO_ROOT}/hosts/docker-linux/base-alpine/Dockerfile")
set(BASE_DEFAULT 
    "${YUNIBASE_REPO_ROOT}/hosts/docker-linux/base-ubuntuLTS/Dockerfile")
set(BASE_UBUNTU32
    "${YUNIBASE_REPO_ROOT}/hosts/docker-linux/base-ubuntu32LTS/Dockerfile")
set(BASE_JAVA
    "${YUNIBASE_REPO_ROOT}/hosts/docker-linux/base-java/Dockerfile")
set(BASE_RASPBIAN
    "${YUNIBASE_REPO_ROOT}/hosts/docker-linux/base-raspbian/Dockerfile")

function(add_docker_build tgt dockerfile tag root)
    add_custom_target(${tgt}
        COMMAND docker build --no-cache
        --tag "${tag}" -f ${dockerfile} ${root}
        COMMENT "Building dockerfile...(${tgt} => ${tag})"
        WORKING_DIRECTORY ${YUNIBASE_REPO_ROOT})
endfunction()

macro(escape_args var first)
    set(${var} "${first}")
    foreach(e ${ARGN})
        set(${var} "${${var}}\\;${e}")
    endforeach()
endmacro()

function(add_docker_yunibase tgt image tag)
    escape_args(_str ${ARGN})
    add_custom_target(${tgt}
        COMMAND ${CMAKE_COMMAND}
        -DIMAGE=${image}
        "-DONLY=${_str}"
        -DLOGFILE=${CMAKE_CURRENT_BINARY_DIR}/${tgt}.log
        -DCIDFILE=${CMAKE_CURRENT_BINARY_DIR}/cid${tgt}
        -DTAG=${tag}
        -DSTAMP=${CMAKE_CURRENT_LIST_DIR}/_stamp.txt
        -P ${CMAKE_CURRENT_LIST_DIR}/docker-run-build.cmake
        COMMENT "Building yunibase image...(${image} => ${tag})")
endfunction()

function(add_docker_push tgt repo)
    add_custom_target(${tgt}
        COMMAND docker push ${repo}
        COMMENT "Push docker image...(${tgt} ${repo})"
        )
endfunction()

#
# BASE IMAGES
#
add_docker_build(docker_base_default
    ${BASE_DEFAULT} "okuoku/yunibuild:latest" ${BUILDCTX_NONE})
add_docker_build(docker_base_ubuntu32
    ${BASE_UBUNTU32} "okuoku/yunibuild:latest-ubuntu32" ${BUILDCTX_NONE})
add_docker_build(docker_base_fedora 
    ${BASE_FEDORA} "okuoku/yunibuild:latest-fedora" ${BUILDCTX_NONE})
add_docker_build(docker_base_alpine
    ${BASE_ALPINE} "okuoku/yunibuild:latest-alpine" ${BUILDCTX_NONE})
add_docker_build(docker_base_java
    ${BASE_JAVA} "okuoku/yunibuild:latest-java" ${BUILDCTX_NONE})
add_docker_build(docker_base_raspbian # multiarch
    ${BASE_RASPBIAN} "okuoku/yunibuild:latest-raspbian" ${BUILDCTX_NONE})
add_docker_push(docker_push_yunibuild "okuoku/yunibuild")

add_dependencies(base docker_base_default docker_base_ubuntu32
    docker_base_fedora docker_base_alpine docker_base_java
    docker_base_raspbian)
add_dependencies(push docker_push_yunibuild)

# 
# Yunibase IMAGES
#
add_docker_yunibase(docker_yuni_default
    "okuoku/yunibuild:latest" "okuoku/yunibase:testing"
    CHIBI_SCHEME GAUCHE NMOSH SAGITTARIUS CHICKEN GUILE RACKET VICARE CHEZ
    GAMBIT 
    # RAPID_GAMBIT
    PICRIN
    MIT_SCHEME
    )
add_docker_yunibase(docker_yuni_ubuntu32
    "okuoku/yunibuild:latest-ubuntu32" "okuoku/yunibase:testing-ubuntu32"
    # Disabled: GUILE VICARE
    CHIBI_SCHEME 
    #25: Disable BoehmGC based impl. for now
    # GAUCHE 
    # NMOSH 
    # SAGITTARIUS 
    CHICKEN RACKET 
    LARCENY CHEZ 
    # FIXME: Gambit crashes on Ubuntu32
    # GAMBIT 
    # RAPID_GAMBIT
    PICRIN
    )
add_docker_yunibase(docker_yuni_fedora
    "okuoku/yunibuild:latest-fedora" "okuoku/yunibase:testing-fedora"
    # Disabled: SAGITTARIUS GUILE
    CHIBI_SCHEME GAUCHE NMOSH CHICKEN RACKET VICARE CHEZ 
    GAMBIT 
    # RAPID_GAMBIT
    PICRIN
    MIT_SCHEME
    )
add_docker_yunibase(docker_yuni_alpine
    "okuoku/yunibuild:latest-alpine" "okuoku/yunibase:testing-alpine"
    CHIBI_SCHEME CHICKEN # CHEZ
    PICRIN
    )

add_docker_yunibase(docker_yuni_java
    "okuoku/yunibuild:latest-java" "okuoku/yunibase:testing-java"
    CHIBI_SCHEME
    KAWA)

add_docker_yunibase(docker_yuni_raspbian
    "okuoku/yunibuild:latest-raspbian" "okuoku/yunibase:testing-raspbian"
    CHIBI_SCHEME
    CHICKEN
    GAMBIT)

add_docker_push(docker_push_yunibase "okuoku/yunibase")

add_dependencies(image docker_yuni_default docker_yuni_ubuntu32
    docker_yuni_fedora docker_yuni_alpine docker_yuni_java
    docker_yuni_raspbian)

add_dependencies(push docker_push_yunibase)

#
# Version stamp
#

add_yunibase_stamp_version(stamp_version
    ${YUNIBASE_REPO_ROOT}
    ${CMAKE_CURRENT_LIST_DIR}/_stamp.txt)
add_dependencies(stamp stamp_version)
add_dependencies(docker_yuni_default stamp)
add_dependencies(docker_yuni_ubuntu32 stamp)
add_dependencies(docker_yuni_fedora stamp)
add_dependencies(docker_yuni_alpine stamp)
add_dependencies(docker_yuni_java stamp)
add_dependencies(docker_yuni_raspbian stamp)

#
# yuniimage
# 

function(add_docker_yuniimage tgt from to)
    add_custom_target(${tgt}
        COMMAND ${CMAKE_COMMAND}
        -DIMAGE=${from}
        -DBUILDYUNI=TRUE
        -DLOGFILE=${CMAKE_CURRENT_BINARY_DIR}/${tgt}.log
        -DCIDFILE=${CMAKE_CURRENT_BINARY_DIR}/cid${tgt}
        -DTAG=${to}
        -DSTAMP=${CMAKE_CURRENT_LIST_DIR}/_stamp.txt
        -P ${CMAKE_CURRENT_LIST_DIR}/docker-run-build.cmake
        COMMENT "Building yuni image...(${from} => ${to})")
    add_dependencies(yuniimage ${tgt})
endfunction()

add_docker_yuniimage(yuniimage_default 
    "okuoku/yunibase:testing" "okuoku/yunibase:latest")
add_docker_yuniimage(yuniimage_ubuntu32
    "okuoku/yunibase:testing-ubuntu32" "okuoku/yunibase:yuni-ubuntu32")
add_docker_yuniimage(yuniimage_fedora
    "okuoku/yunibase:testing-fedora" "okuoku/yunibase:yuni-fedora")
add_docker_yuniimage(yuniimage_java
    "okuoku/yunibase:testing-java" "okuoku/yunibase:yuni-java")
add_docker_yuniimage(yuniimage_alpine
    "okuoku/yunibase:testing-alpine" "okuoku/yunibase:yuni-alpine")
add_docker_yuniimage(yuniimage_raspbian
    "okuoku/yunibase:testing-raspbian" "okuoku/yunibase:yuni-raspbian")

#
# yunitest
# 

function(add_docker_yunitest tgt tag)
    add_custom_target(${tgt}
        COMMAND ${CMAKE_COMMAND}
        -DIMAGE=${tag}
        -P ${YUNIBASE_WITH_YUNI}/integration/buildhost-docker-linux/test-on-docker.cmake
        COMMENT "Testing(${tgt})...")
    add_dependencies(yunitest ${tgt})
endfunction()

if(YUNIBASE_WITH_YUNI)
    add_docker_yunitest(yunitest_default "okuoku/yunibase:testing")
    add_docker_yunitest(yunitest_ubuntu32 "okuoku/yunibase:testing-ubuntu32")
    add_docker_yunitest(yunitest_fedora "okuoku/yunibase:testing-fedora")
    add_docker_yunitest(yunitest_java "okuoku/yunibase:testing-java")
    add_docker_yunitest(yunitest_alpine "okuoku/yunibase:testing-alpine")
    add_docker_yunitest(yunitest_raspbian "okuoku/yunibase:testing-raspbian")
endif()
