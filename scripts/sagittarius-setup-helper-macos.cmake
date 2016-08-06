# Sagittarius setup helper for macOS
#
# INPUT:
#  PTH: Full-path for sagittarius install path

if(NOT EXISTS ${PTH})
    message(FATAL_ERROR "PTH: ${PTH} does not exist")
endif()

set(EXEC ${PTH}/bin/sagittarius)

file(GLOB_RECURSE dylibs "${PTH}/*.dylib")

function(apply_install_name_tool fil)
    execute_process(
        COMMAND
        install_name_tool -change libsagittarius.dylib
        @executable_path/../lib/libsagittarius.dylib
        ${fil}
        RESULT_VARIABLE rr
        )
    if(rr)
        message(WARNING "Failed: ${fil} ${rr}")
    else()
        message(STATUS "Modified: ${fil}")
    endif()
endfunction()

foreach(e ${EXEC} ${dylibs})
    apply_install_name_tool(${e})
endforeach()

