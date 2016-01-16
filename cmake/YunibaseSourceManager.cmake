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
        "${_mypth}" CACHE PATH "(Internal) basepath for ${nam} ${flav}"
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


