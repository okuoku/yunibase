# BuildMgr

macro(init_recipe)
    # Recipe registry for primary rules
    set(__yunibase_buildmgr_recipes "" CACHE STRING "" FORCE)
    mark_as_advanced(__yunibase_buildmgr_recipes)
endmacro()

macro(yunibase_recipe_establish_depends first next)
    add_dependencies(${first} ${next})
    if(NOT "${ARGN}" STREQUAL "")
        yunibase_recipe_establish_depends(${next} ${ARGN})
    endif()
endmacro()

macro(register_recipe nam flav)
    set(_recipes ${ARGN})
    list(REVERSE _recipes)
    list(GET _recipes 0 _first)
    list(LENGTH _recipes _cnt)
    if(NOT ${_cnt} EQUAL 1)
        yunibase_recipe_establish_depends(${_recipes})
    endif()
    list(APPEND __yunibase_buildmgr_recipes "${nam}_${flav}:${_first}")
    set(__yunibase_buildmgr_recipelist_${_first} ${_recipes})
endmacro()

function(init_config_directory)
    if(EXISTS ${YUNIBASE_BUILD_CONFIG_PREFIX})
        if(EXISTS ${YUNIBASE_BUILD_CONFIG_PREFIX}/configured_by_me)
            file(REMOVE_RECURSE ${YUNIBASE_BUILD_CONFIG_PREFIX})
        endif()
    endif()
endfunction()

set(yunibase___step_options
    IGNORE_TEST_FAILURE
    SKIP_BOOTSTRAP
    BOOTSTRAP_ONLY
    SKIP_TEST)

function(yunibase_recipe_configure1 tgt opts)
    set(dir ${YUNIBASE_BUILD_CONFIG_PREFIX}/${tgt})
    set(pth ${dir}/config.cmake)
    file(MAKE_DIRECTORY ${dir})
    file(WRITE ${YUNIBASE_BUILD_CONFIG_PREFIX}/configured_by_me "blah")
    if(EXISTS ${pth})
        message(FATAL_ERROR "Duplicate options?? (${pth})")
    endif()
    # Header
    file(WRITE ${pth} "# Autogenerated. Do not edit.\n\n")
    # Write options
    foreach(e ${yunibase___step_options})
        if("${opts}" MATCHES ${e})
            file(APPEND ${pth} "set(${e} TRUE)\n")
        else()
            file(APPEND ${pth} "set(${e} FALSE)\n")
        endif()
    endforeach()
    message(STATUS "Recipe config(${tgt}): ${opts}")
endfunction()

function(yunibase_recipe_configure tgt opts)
    foreach(e ${__yunibase_buildmgr_recipelist_${tgt}})
        yunibase_recipe_configure1(${e} "${opts}")
    endforeach()
endfunction()

macro(yunibase___set_recipe_state nam flav state)
    foreach(e ${__yunibase_buildmgr_recipes})
        if(${e} MATCHES "${nam}_${flav}:(.*)")
            if(${state})
                message(STATUS "Disable: ${e}")
            else()
                message(STATUS "Enable: ${e}")
            endif()
            set(_tgt ${CMAKE_MATCH_1})
            set_target_properties(${_tgt}
                PROPERTIES
                EXCLUDE_FROM_ALL
                ${state})
            # Check options validity
            foreach(e ${ARGN})
                if(NOT "${yunibase___step_options}" MATCHES ${e})
                    message(FATAL_ERROR "Unknown recipe option: ${e}")
                endif()
            endforeach()
            yunibase_recipe_configure(${_tgt} "${ARGN}")
            break()
        endif()
    endforeach()
endmacro()

function(toggle_recipe_only1 nam state)
    foreach(e ${__yunibase_buildmgr_recipes})
        if(${e} MATCHES "${nam}:(.*)")
            if(${state} STREQUAL FALSE)
                message(STATUS "enable: ${e}")
            else()
                message(STATUS "disable: ${e}")
            endif()
            set(_tgt ${CMAKE_MATCH_1})
            set_target_properties(${_tgt}
                PROPERTIES
                EXCLUDE_FROM_ALL
                ${state})
            break()
        endif()
    endforeach()
endfunction()

function(enable_recipe_only1 nam)
    toggle_recipe_only1(${nam} FALSE)
endfunction()

function(disable_recipe_only1 nam)
    toggle_recipe_only1(${nam} TRUE)
endfunction()

function(enable_recipe_only)
    # First, disable every enabled recipes first
    foreach(e ${__yunibase_buildmgr_recipes})
        if(${e} MATCHES "([^:]*):(.*)")
            set(tgt ${CMAKE_MATCH_1})
            disable_recipe_only1(${tgt})
        endif()
    endforeach()

    # Enable back specified recipes
    foreach(e ${ARGN})
        enable_recipe_only1(${e})
        enable_recipe_only1(${e}_STABLE)
        enable_recipe_only1(${e}_CURRENT)
    endforeach()
endfunction()

function(disable_recipe_only)
    foreach(e ${ARGN})
        disable_recipe_only1(${e})
        disable_recipe_only1(${e}_STABLE)
        disable_recipe_only1(${e}_CURRENT)
    endforeach()
endfunction()

macro(enable_recipe nam flav)
    yunibase___set_recipe_state(${nam} ${flav} FALSE ${ARGN})
endmacro()

macro(disable_recipe nam flav)
    yunibase___set_recipe_state(${nam} ${flav} TRUE)
endmacro()
