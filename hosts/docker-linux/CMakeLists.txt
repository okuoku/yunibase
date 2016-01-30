project(yunibuild-docker-linux)
cmake_minimum_required(VERSION 2.8)

set(YUNIBASE_REPO_ROOT ${CMAKE_CURRENT_LIST_DIR}/../../)
list(APPEND CMAKE_MODULE_PATH ${YUNIBASE_REPO_ROOT}/cmake)

include(YunibaseStampVersion)

add_custom_target(base)   # Update base environment
add_custom_target(sync)   # Update Scheme implementations
add_custom_target(image)  # Build yunibase images
add_custom_target(taste)  # Check latest sources
add_custom_target(push)   # Push built images
add_custom_target(stamp)  # Stamp current repository version

# Globals

# Paths
set(BUILDCTX_NONE 
    "${YUNIBASE_REPO_ROOT}/hosts/docker-linux")
set(BASE_FEDORA 
    "${YUNIBASE_REPO_ROOT}/hosts/docker-linux/base-fedora/Dockerfile")
set(BASE_ALPINE
    "${YUNIBASE_REPO_ROOT}/hosts/docker-linux/base-alpine/Dockerfile")
set(BASE_DEFAULT 
    "${YUNIBASE_REPO_ROOT}/hosts/docker-linux/base-ubuntuLTS/Dockerfile")
set(YUNI_FEDORA 
    "${YUNIBASE_REPO_ROOT}/hosts/docker-linux/Dockerfile.testing-fedora")
set(YUNI_ALPINE
    "${YUNIBASE_REPO_ROOT}/hosts/docker-linux/Dockerfile.testing-alpine")
set(YUNI_DEFAULT 
    "${YUNIBASE_REPO_ROOT}/hosts/docker-linux/Dockerfile.testing")

function(add_docker_build tgt dockerfile tag root)
    add_custom_target(${tgt}
        COMMAND docker build --no-cache
        --tag "${tag}" -f ${dockerfile} ${root}
        COMMENT "Building dockerfile...(${tgt} => ${tag})"
        WORKING_DIRECTORY ${YUNIBASE_REPO_ROOT})
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
add_docker_build(docker_base_fedora 
    ${BASE_FEDORA} "okuoku/yunibuild:latest-fedora" ${BUILDCTX_NONE})
add_docker_build(docker_base_alpine
    ${BASE_ALPINE} "okuoku/yunibuild:latest-alpine" ${BUILDCTX_NONE})
add_docker_push(docker_push_yunibuild "okuoku/yunibuild")

add_dependencies(base docker_base_default docker_base_fedora docker_base_alpine)
add_dependencies(push docker_push_yunibuild)

# 
# Yunibase IMAGES
#
add_docker_build(docker_yuni_default
    ${YUNI_DEFAULT} "okuoku/yunibase:testing" ${YUNIBASE_REPO_ROOT})
add_docker_build(docker_yuni_fedora
    ${YUNI_FEDORA} "okuoku/yunibase:testing-fedora" ${YUNIBASE_REPO_ROOT})
add_docker_build(docker_yuni_alpine
    ${YUNI_ALPINE} "okuoku/yunibase:testing-alpine" ${YUNIBASE_REPO_ROOT})
add_docker_push(docker_push_yunibase "okuoku/yunibase")

add_dependencies(image docker_yuni_default docker_yuni_fedora docker_yuni_alpine)
add_dependencies(push docker_push_yunibase)

#
# Version stamp
#

add_yunibase_stamp_version(stamp_version
    ${YUNIBASE_REPO_ROOT}
    ${CMAKE_CURRENT_LIST_DIR}/_stamp.txt)
add_dependencies(stamp stamp_version)
add_dependencies(docker_yuni_default stamp)
add_dependencies(docker_yuni_fedora stamp)
add_dependencies(docker_yuni_alpine stamp)
