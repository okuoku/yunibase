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

function(enable_recipe_only1 nam)
    foreach(e ${__yunibase_buildmgr_recipes})
        if(${e} MATCHES "${nam}:(.*)")
            message(STATUS "enable: ${e}")
            set(_tgt ${CMAKE_MATCH_1})
            set_target_properties(${_tgt}
                PROPERTIES
                EXCLUDE_FROM_ALL
                FALSE)
            break()
        endif()
    endforeach()
endfunction()

function(enable_recipe_only)
    foreach(e ${ARGN})
        enable_recipe_only1(${e})
        enable_recipe_only1(${e}_STABLE)
        enable_recipe_only1(${e}_CURRENT)
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
