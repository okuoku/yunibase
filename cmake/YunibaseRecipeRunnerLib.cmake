# 

macro(apply_envp ev app)
    set(ENV{${ev}} "${app}:$ENV{${ev}}")
    message(STATUS "ENV: ${ev} = $ENV{${ev}}")
    if("${ARGN}" STREQUAL "")
        # Complete
    else()
        apply_envp(${ARGN})
    endif()
endmacro()

macro(run_step tgt stepname dir cfgdir rptdir logdir envp)
    set(outlog ${logdir}/${tgt}_${stepname}_stdout.log)
    set(errlog ${logdir}/${tgt}_${stepname}_stderr.log)
    file(MAKE_DIRECTORY ${rptdir})
    file(MAKE_DIRECTORY ${logdir})
    if(EXISTS ${cfgdir}/config.cmake)
        include(${cfgdir}/config.cmake)
    endif()
    if("${stepname}" MATCHES "Test")
        set(is_test TRUE)
    else()
        set(is_test FALSE)
    endif()
    if(is_test AND SKIP_TEST)
        message(STATUS "Skip: ${tgt}:${stepname}")
    else()
        message(STATUS "Running ${tgt}:${stepname}")
        foreach(e ${ARGN})
            message(STATUS " ${e}")
        endforeach()
        execute_process(COMMAND ${ARGN}
            WORKING_DIRECTORY ${dir}
            OUTPUT_FILE ${outlog}
            ERROR_FILE ${errlog}
            RESULT_VARIABLE rr)
        if(rr)
            file(READ ${outlog} log_out)
            file(READ ${errlog} log_err)
            message(STATUS "stdout(${tgt}_${stepname}):")
            message("${log_out}")
            message(STATUS "stderr(${tgt}_${stepname}):")
            message("${log_err}")
            if(is_test AND IGNORE_TEST_FAILURE)
                message(STATUS "Error in ${tgt}_${stepname} (ignored)")
            else()
                message(FATAL_ERROR "Error in ${tgt}_${stepname}")
            endif()
        endif()
    endif()
    message(STATUS "Done ${tgt}:${stepname}")
endmacro()
