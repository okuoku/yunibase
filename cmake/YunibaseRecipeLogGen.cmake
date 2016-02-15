# Generate build final reports

# INPUTs:
#   TOTAL: full path for total.cmake
include(${TOTAL})

foreach(e ${recipelogprefixes})
    if(recipelogprefix_${e})
        foreach(nam ${recipelogprefix_${e}})
            if(${nam}_steps)
                foreach(step ${${nam}_steps})
                    set(_result ${${nam}_${step}_RESULT})
                    set(_duration ${${nam}_${step}_DURATION})
                    set(_timestamp ${${nam}_${step}_TIMESTAMP})
                    message(STATUS "${e} ${nam} ${step} :: ${_result} ${_duration}")
                endforeach()
            else()
                message(STATUS "${nam} build error..?")
            endif()
        endforeach()
    else()
        message(STATUS "${e} was not built??")
    endif()
endforeach()
