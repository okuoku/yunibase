cmake_minimum_required(VERSION 3.2)
project(yunibuild-docker-linux NONE)

set(YUNIBASE_REPO_ROOT ${CMAKE_CURRENT_LIST_DIR}/../..)
list(APPEND CMAKE_MODULE_PATH ${YUNIBASE_REPO_ROOT}/cmake)

include(YunibaseStampVersion)
include(YunibaseWorkaroundFileTimestamp) # Needs YUNIBASE_REPO_ROOT

workaround_yunibase_impl_stable_timestamps()

add_custom_target(base)   # Update base environment
add_custom_target(sync)   # Update Scheme implementations
add_custom_target(image)  # Build yunibase images (without yuni)
add_custom_target(yuniimage) # Install yuni on yunibase images
add_custom_target(push)   # Push built images
add_custom_target(stamp)  # Stamp current repository version
add_custom_target(yunitest) # Test with ${YUNIBASE_WITH_YUNI}
add_custom_target(deploylocal) # Deploy generated .tar.gz under /opt/yunibase/

add_custom_target(update-tagfiles) # Update tagfiles (internal target)

set(impls)

macro(register_impl sym nam)
    set(_lis ${ARGN})
    list(FIND _lis REQUIRE_STABLE qq)
    if(NOT ${qq} EQUAL -1)
        set(impl_${sym}_REQUIRE_STABLE ON)
    endif()
    list(FIND _lis REQUIRE_YUNI qq)
    if(NOT ${qq} EQUAL -1)
        set(impl_${sym}_REQUIRE_YUNI ON)
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

macro(impl_require_yuni_p var sym)
    if(impl_${sym}_REQUIRE_YUNI)
        set(${var} ON)
    else()
        set(${var} OFF)
    endif()
endmacro()

# FIXME: Use Git-archive deploy later
set(sourcesyms)
macro(register_source sym branch pth mode tag)
    if(${branch} STREQUAL DEP)
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
macro(source_add_yunisrcdep sym)
    list(APPEND impl_${sym}_CURRENT_sourcesyms yunisrc_NONE)
endmacro()

set(tree CURRENT)
set(source_root ${YUNIBASE_REPO_ROOT})
include(${YUNIBASE_REPO_ROOT}/sources-current.cmake)
set(source_root ${YUNIBASE_REPO_ROOT}/impl-stable)
set(tree STABLE)
include(${YUNIBASE_REPO_ROOT}/impl-stable/sources.cmake)

function(add_source_gentag dest sourcesym)
    set(tgt update-tag-${sourcesym})
    add_custom_target(${tgt}
        COMMAND ${CMAKE_COMMAND} 
        -DTAGPROTOCOL=${source_${sourcesym}_tagprotocol}
        -DTAG=${source_${sourcesym}_tag}
        -DTAGPATH=${source_${sourcesym}_tagpath}
        -DDEST=${dest}
        -P ${YUNIBASE_REPO_ROOT}/hosts/docker-linux/update-tagfile.cmake
        BYPRODUCTS ${dest}
        COMMENT "Updating tagfile for ${sourcesym}")
    add_dependencies(update-tagfiles ${tgt})
    message(STATUS "Tagfile: ${sourcesym} => ${dest}")
endfunction()

macro(impl_sourcesyms var sym branch)
    set(${var} ${impl_${sym}_${branch}_sourcesyms})
endmacro()

# Special handling for yunisrc
set(source_root ${YUNIBASE_REPO_ROOT})
register_source(yunisrc NONE yuni GIT "origin/master")

# Globals
set(YUNIBASE_MASTER_REMOTE "none" 
    CACHE STRING "Master Git local name to sync with")

# FIXME: Deprecate it
if(NOT ${YUNIBASE_MASTER_REMOTE} STREQUAL "none")
    add_custom_target(try-master-sync
        COMMAND git fetch ${YUNIBASE_MASTER_REMOTE}
        COMMAND git reset --hard ${YUNIBASE_MASTER_REMOTE}/master
        COMMAND git submodule update --init --recursive
        WORKING_DIRECTORY ${YUNIBASE_REPO_ROOT})
    add_custom_target(TARGET try-master-sync
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} --build ${CMAKE_CURRENT_BINARY_DIR}
        --target update-tagfiles
        COMMENT "Updating tagfiles...")
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
# Version stamp (for docker image)
#

add_yunibase_stamp_version(stamp_version
    ${YUNIBASE_REPO_ROOT}
    ${CMAKE_CURRENT_LIST_DIR}/_stamp.txt)
add_dependencies(stamp stamp_version)

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
    set(archiveroot ${CMAKE_CURRENT_BINARY_DIR}/archive)
    archive_name(archivename ${impl} ${branch} ${rootname})
    set(dest ${archiveroot}/${archivename})
    if(${branch} STREQUAL STABLE)
        set(targetname archive-${implnam}-stable)
        set(stabledepends)
        set(prebuilt_stablearg)
    else()
        set(targetname archive-${implnam}-current)
        impl_require_stable_p(require_stable ${impl})
        if(require_stable)
            # Generate dependency with stable build
            archive_name(stablename ${impl} STABLE ${rootname})
            set(stabledepends ${archiveroot}/${stablename})
            set(prebuilt_stablearg "-DPREBUILT_STABLE=${stablename}")
        else()
            set(stabledepends)
            set(prebuilt_stablearg)
        endif()
        impl_require_yuni_p(require_yuni ${impl})
        if(require_yuni)
            source_add_yunisrcdep(${impl})
        endif()
    endif()
    impl_sourcesyms(syms ${impl} ${branch})
    set(tagfiles)
    foreach(s ${syms})
        message(STATUS "${dest}: ${s}")
        list(APPEND tagfiles ${tagfileroot}/${s}.tag)
    endforeach()
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
        DEPENDS ${stabledepends} ${tagfiles}
        COMMENT "Building impl archive(${impl}_${branch} with ${rootname})")
    # Deploylocal
    if(${rootname} STREQUAL ubuntu64 AND ${branch} STREQUAL CURRENT)
        add_custom_target(deploylocal-${impl}
            COMMAND ${CMAKE_COMMAND}
            -DARCHIVE=${dest}
            -DIMPLNAM=${implnam}
            -P ${CMAKE_CURRENT_LIST_DIR}/deploylocal.cmake)
        add_dependencies(deploylocal deploylocal-${impl})
    elseif(${rootname} STREQUAL ubuntu64 AND ${branch} STREQUAL STABLE)
        # Special: SCM has stable build
        if(${impl} STREQUAL SCM)
            add_custom_target(deploylocal-${impl}
                COMMAND ${CMAKE_COMMAND}
                -DARCHIVE=${dest}
                -DIMPLNAM=${implnam}
                -DBRANCH=${branch}
                -P ${CMAKE_CURRENT_LIST_DIR}/deploylocal.cmake)
            add_dependencies(deploylocal deploylocal-${impl})
        endif()
    endif()
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
        if(${impl} STREQUAL SCM)
            # Special: SCM only have stable variant
            add_docker_archive_build(${impl} STABLE ${rootname})
        else()
            add_docker_archive_build(${impl} CURRENT ${rootname})
        endif()
    endforeach()
endmacro()

function(add_docker_yunibase tgt rootname) # only for enable_impl
    # FIXME: Special handling for "ubuntu64" (as it is default)
    if(${rootname} STREQUAL ubuntu64)
        set(tagsufx "")
    else()
        set(tagsufx "-${rootname}")
    endif()
    set(image "okuoku/yunibuild:latest${tagsufx}")
    set(tag "okuoku/yunibase:testing${tagsufx}")
    set(archiveroot ${CMAKE_CURRENT_BINARY_DIR}/archive)
    add_custom_target(${tgt}
        COMMAND ${CMAKE_COMMAND}
        -DIMAGE=${image}
        -DLOGFILE=${CMAKE_CURRENT_BINARY_DIR}/${tgt}.log
        -DCIDFILE=${CMAKE_CURRENT_BINARY_DIR}/cid${tgt}
        -DTAG=${tag}
        -DSTAMP=${CMAKE_CURRENT_LIST_DIR}/_stamp.txt
        -DARCHIVEDIR=${archiveroot}
        -DARCHIVEPREFIX=${rootname}
        -P ${CMAKE_CURRENT_LIST_DIR}/docker-run-build.cmake
        COMMENT "Building yunibase image...(${image} => ${tag})")
    add_dependencies(image ${tgt})
endfunction()

macro(enable_impl rootname)
    set(_archiveroot ${CMAKE_CURRENT_BINARY_DIR}/archive)
    set(_archivepaths)
    foreach(impl ${ARGN})
        set(_archivename)
        if(${impl} STREQUAL SCM)
            # Special: SCM only have stable build
            archive_name(_archivename ${impl} STABLE ${rootname})
        else()
            archive_name(_archivename ${impl} CURRENT ${rootname})
        endif()
        if(_archivename)
            list(APPEND _archivepaths ${_archiveroot}/${_archivename})
        else()
            message(STATUS "WARNING: ${impl} did not found in distrib")
        endif()
    endforeach()
    add_custom_target(archives-${rootname}
        DEPENDS ${_archivepaths})
    add_docker_yunibase(image-${rootname} ${rootname})
    add_dependencies(image-${rootname} archives-${rootname} stamp)
endmacro()

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/archive)

add_root(ubuntu64 ubuntuLTS)

enable_impl(ubuntu64
    CHIBI_SCHEME GAUCHE NMOSH 
    SAGITTARIUS 
    CHICKEN 
    CHICKEN5
    GUILE GUILE3 RACKET VICARE CHEZ
    GAMBIT PICRIN 
    #MIT_SCHEME 
    CYCLONE
    S7YUNI SCM STKLOS DIGAMMA
    FOMENT
    BIGLOO
    KAWA
    )

function(add_docker_push tgt repo)
    add_custom_target(${tgt}
        COMMAND docker push ${repo}
        COMMENT "Push docker image...(${tgt} ${repo})"
        )
endfunction()

add_docker_push(docker_push_yunibuild "okuoku/yunibuild")
add_dependencies(push docker_push_yunibuild)

add_docker_push(docker_push_yunibase "okuoku/yunibase")
add_dependencies(push docker_push_yunibase)

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
endif()

add_subdirectory(updater)
