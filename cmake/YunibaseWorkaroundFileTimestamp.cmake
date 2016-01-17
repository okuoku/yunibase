function(workaround_touch_prebuilt_files base)
    foreach(e ${ARGN})
        message(STATUS "Workaround: Touch ${base}/${e}")
        execute_process(COMMAND
            ${CMAKE_COMMAND} -E touch_nocreate ${base}/${e}
            # Ignore error
            )
    endforeach()
endfunction()
