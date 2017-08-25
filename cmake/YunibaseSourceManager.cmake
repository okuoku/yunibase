# SrcMgr
#
# We hold list of sources into CMake cache so we can access them across
# subdirs.

macro(init_sources)
    # FIXME: Integrate srcs into srcsidx
    set(__yunibase_srcmgr_srcs "" CACHE STRING "" FORCE)
    mark_as_advanced(__yunibase_srcmgr_srcs)
    set(__yunibase_srcmgr_srcsidx "" CACHE STRING "" FORCE)
    mark_as_advanced(__yunibase_srcmgr_srcsidx)
endmacro()

macro(register_source nam flav pth type tag)
    # mypath
    get_filename_component(_mypath "${CMAKE_CURRENT_LIST_DIR}/${pth}" ABSOLUTE)
    message(STATUS "Adding ${nam} ${flav} :  ${_mypath}")
    # ident
    string(REPLACE / _ _ident ${pth})
    # Add to list
    list(APPEND __yunibase_srcmgr_srcs "${nam}:${flav}")
    list(APPEND __yunibase_srcmgr_srcsidx "${_ident}")

    # Properties
    set(__yunibase_srcmgr_${nam}_${flav}_path
        "${_mypath}" CACHE PATH "(Internal) basepath for ${nam} ${flav}"
        FORCE)
    mark_as_advanced(__yunibase_srcmgr_${nam}_${flav}_path)
    set(__yunibase_srcmgr_${_ident}_path
        "${_mypath}" CACHE PATH "(Internal) basepath for ${nam} ${flav}"
        FORCE)
    mark_as_advanced(__yunibase_srcmgr_${_ident}_path)
    set(__yunibase_srcmgr_${nam}_${flav}_ident
        "${_ident}" CACHE PATH "(Internal) ident for ${nam} ${flav}"
        FORCE)
    mark_as_advanced(__yunibase_srcmgr_${nam}_${flav}_ident)
    set(__yunibase_srcmgr_${_ident}_type
        "${type}" CACHE STRING "(Internal) type for ${nam} ${flav}"
        FORCE)
    mark_as_advanced(__yunibase_srcmgr_${_ident}_type)
    set(__yunibase_srcmgr_${_ident}_tag
        "${tag}" CACHE STRING "(Internal) tag for ${nam} ${flav}"
        FORCE)
    mark_as_advanced(__yunibase_srcmgr_${_ident}_tag)

    # Add GIT handlers
    if(${type} STREQUAL "GIT")
        register_git_repository(${nam} ${_mypath} ${tag})
    endif()
endmacro()

macro(detect_source var nam flav)
    set(_varname __yunibase_srcmgr_${nam}_${flav}_path)
    set(_detected)
    # NB: Do always check source validity
    foreach(e ${__yunibase_srcmgr_srcs})
        if(${e} STREQUAL "${nam}:${flav}")
            set(_detected 1)
            break()
        endif()
    endforeach()
    if(_detected AND EXISTS ${${_varname}})
        set(${var} ${${_varname}})
    else()
        set(${var} FALSE)
    endif()
endmacro()

function(register_update_one ident)
    message(STATUS "ident: ${ident}")
    if(${__yunibase_srcmgr_${ident}_type} STREQUAL GIT)
        set(pth ${__yunibase_srcmgr_${ident}_path})
        set(tag ${__yunibase_srcmgr_${ident}_tag})
        set(tgt do-try-update-${ident})

        if(NOT IS_DIRECTORY ${pth})
            message(FATAL_ERROR "Something wrong ${nam} ${flav}")
        endif()

        if(${pth} STREQUAL ${CMAKE_SOURCE_DIR})
            message(FATAL_ERROR "Something wrong ${nam} ${flav}")
        endif()

        add_custom_target(${tgt}
            COMMAND git fetch
            COMMAND git reset --hard ${tag}
            WORKING_DIRECTORY ${pth})
        add_dependencies(do-try-update-all-commit ${tgt})
    endif()
endfunction()

function(register_update_all)
    add_custom_target(do-try-update-all-commit
        COMMAND git commit -a -m "Update Implementations"
        COMMAND git submodule update --init --recursive
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        )
    foreach(e ${__yunibase_srcmgr_srcsidx})
        register_update_one(${e})
    endforeach()

    # Enforce reconfigure to touch-workaround stable flav
    add_custom_target(try-update-all
        COMMAND ${CMAKE_COMMAND} .
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
    add_dependencies(try-update-all do-try-update-all-commit)
endfunction()

