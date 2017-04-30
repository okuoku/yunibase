# Sagittarius setup helper for macOS
#
# INPUT:
#  PTH: Full-path for sagittarius install path

if(NOT EXISTS ${PTH})
    message(FATAL_ERROR "PTH: ${PTH} does not exist")
endif()

set(EXEC ${PTH}/bin/sagittarius)

file(GLOB_RECURSE dylibs "${PTH}/*.dylib")

set(libsagittarius_name)

function(apply_install_name_tool fil)
    execute_process(
        COMMAND
        install_name_tool -change ${libsagittarius_name}
        @executable_path/../lib/${libsagittarius_name}
        ${fil}
        RESULT_VARIABLE rr
        )
    if(rr)
        message(WARNING "Failed: ${fil} ${rr}")
    else()
        message(STATUS "Modified: ${fil}")
    endif()
endfunction()

foreach(e ${dylibs})
    get_filename_component(base ${e} NAME)
    if(${base} MATCHES "libsagittarius\\.[0-9]+\\.[0-9]+\\.[0-9]+\\.dylib")
        if(libsagittarius_name)
            message(STATUS
                "Multiple libsagittarius found! before: ${libsagittarius_name_full} after: ${e}")
        endif()
        set(libsagittarius_name_full ${e})
        set(libsagittarius_name ${CMAKE_MATCH_0})
    endif()
endforeach()

if(NOT libsagittarius_name)
    message(FATAL_ERROR "libsagittarius not found in ${dylibs}")
endif()

foreach(e ${EXEC} ${dylibs})
    apply_install_name_tool(${e})
endforeach()

