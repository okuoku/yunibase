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

macro(run_step tgt stepname dir logdir envp)
    set(outlog ${logdir}/${tgt}_${stepname}_stdout.log)
    set(errlog ${logdir}/${tgt}_${stepname}_stderr.log)
    file(MAKE_DIRECTORY ${logdir})
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
        message(FATAL_ERROR "Error in ${tgt}_${stepname}")
    endif()
    message(STATUS "Done ${tgt}:${stepname}")
endmacro()
