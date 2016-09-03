# SrcMgr
#
# We hold list of sources into CMake cache so we can access them across
# subdirs.

macro(init_sources)
    set(__yunibase_srcmgr_srcs "" CACHE STRING "" FORCE)
    mark_as_advanced(__yunibase_srcmgr_srcs)
endmacro()

macro(register_source nam flav pth type tag)
    # mypath
    get_filename_component(_mypath "${CMAKE_CURRENT_LIST_DIR}/${pth}" ABSOLUTE)
    message(STATUS "Adding ${nam} ${flav} :  ${_mypath}")
    # Add to list
    list(APPEND __yunibase_srcmgr_srcs "${nam}:${flav}")

    # Properties
    set(__yunibase_srcmgr_${nam}_${flav}_path
        "${_mypath}" CACHE PATH "(Internal) basepath for ${nam} ${flav}"
        FORCE)
    mark_as_advanced(__yunibase_srcmgr_${nam}_${flav}_path)
    set(__yunibase_srcmgr_${nam}_${flav}_type
        "${type}" CACHE STRING "(Internal) type for ${nam} ${flav}"
        FORCE)
    mark_as_advanced(__yunibase_srcmgr_${nam}_${flav}_type)
    set(__yunibase_srcmgr_${nam}_${flav}_tag
        "${tag}" CACHE STRING "(Internal) tag for ${nam} ${flav}"
        FORCE)
    mark_as_advanced(__yunibase_srcmgr_${nam}_${flav}_tag)

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

function(register_update_all)
    add_custom_target(do-try-update-all
        COMMAND git submodule foreach git fetch
        # FIXME: Use repository database
        COMMAND git submodule foreach git reset --hard origin/master
        COMMAND git commit -a -m "Update Implementations"
        COMMAND git submodule update --init --recursive
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        )
    # Enforce reconfigure to touch-workaround stable flav
    add_custom_target(try-update-all
        COMMAND ${CMAKE_COMMAND} .
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
    add_dependencies(try-update-all do-try-update-all)
endfunction()

