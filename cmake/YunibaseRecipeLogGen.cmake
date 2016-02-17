# Generate build final reports

# INPUTs:
#   TOTAL: full path for total.cmake
#   REPORT: full path for report.cmake
include(${TOTAL})

if(REPORT)
    file(WRITE ${REPORT} "# Report.cmake\nset(report_prefixes)\n")
endif()

function(do_report prefix nam step result duration)
    if(REPORT)
        file(APPEND ${REPORT}
            "set(report_${prefix}_${nam}_${step} ${nam} ${step} ${result} ${duration})\n")
        file(APPEND ${REPORT}
            "list(APPEND report_prefixes report_${prefix}_${nam}_${step})")
    endif()
endfunction()

foreach(e ${recipelogprefixes})
    if(recipelogprefix_${e})
        foreach(nam ${recipelogprefix_${e}})
            if(${nam}_steps)
                foreach(step ${${nam}_steps})
                    if(${nam}_${step}_RESULT)
                        set(_result ${${nam}_${step}_RESULT})
                        set(_duration ${${nam}_${step}_DURATION})
                        set(_timestamp ${${nam}_${step}_TIMESTAMP})
                        message(STATUS "${e} ${nam} ${step} :: ${_result} ${_duration}")
                        do_report(${e} ${nam} ${step} ${_result} ${_duration})
                    endif()
                endforeach()
            else()
                message(STATUS "${nam} build error..?")
            endif()
        endforeach()
    else()
        message(STATUS "${e} was not built??")
    endif()
endforeach()
