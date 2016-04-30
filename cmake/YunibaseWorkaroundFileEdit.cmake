function(workaround_file_edit pth regex_from to)
    message(STATUS "Workaround: Edit ${pth}: \"${regex_from}\" => \"${to}\"")
    file(READ ${pth} contents)
    # Esc
    # ref: http://stackoverflow.com/questions/30226775/
    string(ASCII 1 _ESC)
    string(ASCII 2 _ESC2)
    # Concat 
    string(REGEX REPLACE ";" "${_ESC2}" contents "${contents}")
    # Split
    string(REGEX REPLACE "\n" "${_ESC};" contents "${contents}")
    unset(_out)
    foreach(e ${contents})
        if("${e}" MATCHES "${regex_from}")
            string(REGEX REPLACE "${regex_from}" "${to}" rep "${e}")
            # message(STATUS "Match: ${e} => ${rep}")
        else()
            # message(STATUS "${e}")
            set(rep "${e}")
        endif()
        string(REGEX REPLACE "${_ESC}" "\n" rep "${rep}")
        set(_out "${_out}${rep}")
    endforeach()
    # Split back
    string(REGEX REPLACE "${_ESC2}" ";" _out "${_out}")
    # message(STATUS "Out: ${_out}")
    file(WRITE ${pth} "${_out}")
endfunction()
