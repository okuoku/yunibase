# BuildMgr

macro(init_recipe)
    set(__yunibase_buildmgr_recipes "" CACHE STRING "" FORCE)
    mark_as_advanced(__yunibase_buildmgr_recipes)
endmacro()

macro(register_recipe nam flav tgt)
    list(APPEND __yunibase_buildmgr_recipes "${nam}_${flav}:${tgt}")
endmacro()


macro(yunibase___set_recipe_state nam flav state)
    foreach(e ${__yunibase_buildmgr_recipes})
        if(${e} MATCHES "${nam}_${flav}:(.*)")
            message(STATUS "state: ${e} ${state}")
            set(_tgt ${CMAKE_MATCH_1})
            set_target_properties(${_tgt}
                PROPERTIES
                EXCLUDE_FROM_ALL
                ${state})
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
    # FIXME: Confusing.. invert it?
    yunibase___set_recipe_state(${nam} ${flav} FALSE)
endmacro()

macro(disable_recipe nam flav)
    # FIXME: Confusing.. invert it?
    yunibase___set_recipe_state(${nam} ${flav} TRUE)
endmacro()
