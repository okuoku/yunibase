cmake_minimum_required(VERSION 2.8)
project(yunibuild-docker-linux NONE)

set(YUNIBASE_REPO_ROOT ${CMAKE_CURRENT_LIST_DIR}/../..)
list(APPEND CMAKE_MODULE_PATH ${YUNIBASE_REPO_ROOT}/cmake)

include(YunibaseStampVersion)

add_custom_target(base)   # Update base environment
add_custom_target(sync)   # Update Scheme implementations
add_custom_target(image)  # Build yunibase images (without yuni)
add_custom_target(yuniimage) # Install yuni on yunibase images
add_custom_target(push)   # Push built images
add_custom_target(stamp)  # Stamp current repository version
add_custom_target(yunitest) # Test with ${YUNIBASE_WITH_YUNI}

set(impls)

macro(register_impl sym nam)
    list(FIND ARGN REQUIRE_STABLE qq)
    if(NOT ${qq} EQUAL -1)
        set(impl_${sym}_REQUIRE_STABLE ON)
    endif()
    list(APPEND impls ${sym})
    set(impl_${sym}_name ${nam})
endmacro()

include(${YUNIBASE_REPO_ROOT}/parts/distrib.cmake)

macro(impl_name var sym)
    if(impl_${sym}_name)
        set(${var} ${impl_${sym}_name})
    endif()
endmacro()

macro(impl_require_stable_p var sym)
    if(impl_${sym}_REQUIRE_STABLE)
        set(${var} ON)
    else()
        set(${var} OFF)
    endif()
endmacro()

# FIXME: Use Git-archive deploy later
set(sourcesyms)
macro(register_source sym branch pth mode tag)
    if(${mode} STREQUAL DEP)
        # Dependencies
        get_filename_component(dirname ${pth} NAME)
        set(sourcesym ${sym}_DEP_${dirname})
        list(APPEND impl_${sym}_CURRENT_sourcesyms ${sourcesym})
    else()
        # STABLE or CURRENT
        set(sourcesym ${sym}_${branch})
        list(APPEND impl_${sym}_${branch}_sourcesyms ${sourcesym})
    endif()
    set(source_${sourcesym}_tagprotocol ${mode})
    set(source_${sourcesym}_tag ${tag})
    set(source_${sourcesym}_tagpath ${source_root}/${pth})
    list(APPEND sourcesyms ${sourcesym})
endmacro()

set(tree CURRENT)
set(source_root ${YUNIBASE_REPO_ROOT})
include(${YUNIBASE_REPO_ROOT}/sources-current.cmake)
set(source_root ${YUNIBASE_REPO_ROOT}/impl-stable)
set(tree STABLE)
include(${YUNIBASE_REPO_ROOT}/impl-stable/sources.cmake)

function(add_source_gentag dest sourcesym)
    add_custom_command(OUTPUT ${dest}
        COMMAND ${CMAKE_COMMAND} 
        -DTAGPROTOCOL=${source_${sourcesym}_tagprotocol}
        -DTAG=${source_${sourcesym}_tag}
        -DTAGPATH=${source_${sourcesym}_tagpath}
        -DDEST=${dest}
        -P ${YUNIBASE_REPO_ROOT}/hosts/docker-linux/update-tagfile.cmake
        COMMEND "Updating tagfile for ${sourcesym}")
endfunction()

macro(impl_sourcesyms var sym branch)
    set(${var} impl_${sym}_${branch}_sourcesyms)
endmacro()

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

#
# Source tags
#
#   Source tags are located in ${CMAKE_CURRENT_BINARY_DIR}/tags and
#   triggers docker-builds.
#

set(tagfileroot ${CMAKE_CURRENT_BINARY_DIR}/tags)

file(MAKE_DIRECTORY ${tagfileroot})

foreach(sourcesym ${sourcesyms})
    add_source_gentag(${tagfileroot}/${sourcesym}.tag ${sourcesym})
endforeach()

#
# Docker builds
#

function(add_docker_build tgt dockerfile tag root) # Only for add_root
    add_custom_target(${tgt}
        COMMAND docker build --no-cache
        --tag "${tag}" -f ${dockerfile} ${root}
        COMMENT "Building dockerfile...(${tgt} => ${tag})"
        WORKING_DIRECTORY ${YUNIBASE_REPO_ROOT})
endfunction()

macro(archive_name var impl branch rootname)
    set(_implnam)
    impl_name(_implnam ${impl})
    if(_implnam)
        if(${branch} STREQUAL STABLE)
            set(${var} yunibase_${rootname}_${_implnam}_stable.tar.gz)
        else()
            set(${var} yunibase_${rootname}_${_implnam}_current.tar.gz)
        endif()
    endif()
endmacro()

function(add_docker_archive_build impl branch rootname)
    # FIXME: Special handling for "ubuntu64" (as it is default)
    if(${rootname} STREQUAL ubuntu64)
        set(tagsufx "")
    else()
        set(tagsufx "-${rootname}")
    endif()
    impl_name(implnam ${impl})
    impl_require_stable_p(require_stable ${impl})
    set(archiveroot ${CMAKE_CURRENT_BINARY_DIR}/archive)
    archive_name(archivename ${impl} ${branch} ${rootname})
    set(dest ${archiveroot}/${archivename})
    if(${branch} STREQUAL STABLE)
        set(targetname archive-${implnam}-stable)
    else()
        set(targetname archive-${implnam}-current)
    endif()
    if(require_stable)
        # Generate dependency with stable build
        archive_name(stablename ${impl} STABLE ${rootname})
        set(stabledepends ${archiveroot}/${stablename})
        set(prebuilt_stablearg "-DPREBUILT_STABLE=${stablename}")
    else()
        set(stabledepends)
        set(prebuilt_stablearg)
    endif()
    add_custom_command(OUTPUT ${dest}
        COMMAND ${CMAKE_COMMAND}
        -DIMAGE="okuoku/yunibuild:latest${tagsufx}"
        -DLOGFILE=${CMAKE_CURRENT_BINARY_DIR}/${rootname}_${impl}_${branch}_log.txt
        -DARCHIVEDIR=${archiveroot}
        -DARCHIVEPREFIX=${rootname}
        -DTARGET=${targetname}
        ${prebuilt_stablearg}
        -DONLY=${impl}
        -P ${CMAKE_CURRENT_LIST_DIR}/docker-build-archive.cmake
        # FIXME: Add tagfile here
        DEPENDS ${stabledepends}
        COMMENT "Building impl archive(${impl}_${branch} with ${rootname})")
endfunction()

macro(add_root rootname ctxname)
    # FIXME: Special handling for "ubuntu64" (as it is default)
    if(${rootname} STREQUAL ubuntu64)
        set(tagsufx "")
    else()
        set(tagsufx "-${rootname}")
    endif()

    # Generate base target
    set(tgt_base docker_base_${rootname})
    add_docker_build(${tgt_base}
        # Dockerfile
        "${YUNIBASE_REPO_ROOT}/hosts/docker-linux/base-${ctxname}/Dockerfile"
        # Tag
        "okuoku/yunibuild:latest${tagsufx}"
        # Build context
        "${YUNIBASE_REPO_ROOT}/hosts/docker-linux")
    add_dependencies(base ${tgt_base})

    # Generate per-impl build targets
    foreach(impl ${impls})
        impl_require_stable_p(require_stable ${impl})
        impl_name(implnam ${impl})
        if(require_stable)
            add_docker_archive_build(${impl} STABLE ${rootname})
        endif()
        add_docker_archive_build(${impl} CURRENT ${rootname})
    endforeach()
endmacro()

macro(enable_impl rootname)
    set(_archiveroot ${CMAKE_CURRENT_BINARY_DIR}/archive)
    set(_archivepaths)
    foreach(impl ${ARGN})
        set(_archivename)
        archive_name(_archivename ${impl} CURRENT ${rootname})
        if(_archivename)
            list(APPEND _archivepaths ${_archiveroot}/${_archivename})
        else()
            message(STATUS "WARNING: ${impl} did not found in distrib")
        endif()
    endforeach()
    add_custom_target(archives-${rootname}
        DEPENDS ${_archivepaths})
endmacro()

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/archive)

add_root(ubuntu64 ubuntuLTS)
add_root(fedora fedora)
add_root(alpine alpine)
add_root(ubuntu32 ubuntu32LTS)
add_root(java java)
add_root(raspbian raspbian)

enable_impl(ubuntu64
    CHIBI_SCHEME GAUCHE NMOSH SAGITTARIUS CHICKEN GUILE RACKET VICARE CHEZ
    GAMBIT PICRIN MIT_SCHEME)
enable_impl(ubuntu32
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
    PICRIN)
enable_impl(fedora
    # Disabled: SAGITTARIUS GUILE
    CHIBI_SCHEME GAUCHE NMOSH CHICKEN RACKET VICARE CHEZ 
    GAMBIT 
    PICRIN
    MIT_SCHEME)
enable_impl(alpine
    CHIBI_SCHEME CHICKEN # CHEZ
    PICRIN)
enable_impl(java
    CHIBI_SCHEME
    KAWA)
enable_impl(raspbian
    CHIBI_SCHEME
    CHICKEN
    GAMBIT)

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

add_docker_push(docker_push_yunibuild "okuoku/yunibuild")

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
