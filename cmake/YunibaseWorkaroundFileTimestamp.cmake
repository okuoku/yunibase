find_program(workaround_touch_use_touch_command
    touch)
function(workaround_touch_prebuilt_files base)
    # FIXME: Special WAR for absolute paths
    if("${base}" STREQUAL "/")
        set(pths ${ARGN})
    else()
        set(pths)
        foreach(e ${ARGN})
            list(APPEND pths ${base}/${e})
        endforeach()
    endif()
    if(workaround_touch_use_touch_command)
        message(STATUS "Workaround: Touch (w/ touch)")
        foreach(e ${pths})
            message(STATUS "${e}")
        endforeach()
        execute_process(COMMAND
            ${workaround_touch_use_touch_command}
            ${pths})
    else()
        foreach(e ${pths})
            message(STATUS "Workaround: Touch ${base}/${e}")
            execute_process(COMMAND
                ${CMAKE_COMMAND} -E touch_nocreate ${base}/${e}
                # Ignore error
                )
        endforeach()
    endif()
endfunction()
