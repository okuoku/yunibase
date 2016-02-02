# Bootstrap in Cygwin, build in MSYS

# In msys64:
#
#   [msys64]/yunisrc/yunibase.win32
#   [msys64]/yunisrc/yunibase.win64
#   [msys64]/build.cygwinboot - Bootstrap
#   [msys64]/build.msys

set(_mydir ${CMAKE_CURRENT_LIST_DIR})
get_filename_component(_mysrc ${_mydir}/../.. ABSOLUTE)
execute_process(
    # -a is for absolute
    COMMAND cygpath -a ${CMAKE_CURRENT_BINARY_DIR}/msys64
    WORKING_DIRECTORY cyg64/bin
    OUTPUT_STRIP_TRAILING_WHITESPACE
    OUTPUT_VARIABLE out
    RESULT_VARIABLE rr)

if(rr)
    message(FATAL_ERROR "Cannot translate MSYS rootpath ${rr}")
endif()

set(_msysloc ${out})

message(STATUS "Location(cygwin): [${_msysloc}]")


# Construct directories
function(construct_tree sufx)
    message(STATUS "Generating source tree(${sufx})")
    file(MAKE_DIRECTORY msys64/yunisrc)
    file(COPY ${_mysrc} DESTINATION msys64/yunisrc
        PATTERN ".git" EXCLUDE)
    file(RENAME msys64/yunisrc/yunibase msys64/yunisrc/yunibase.${sufx})

    # Bootstrap on Cygwin
    execute_process(
        COMMAND cyg64/bin/bash -l -c
        "cmake -DEXCEPT=VICARE\;GUILE -DBOOTSTRAP_ONLY=TRUE -DINPLACE=TRUE -DBUILDROOT=/build.cygwinboot-${sufx} -P ${_msysloc}/yunisrc/yunibase.${sufx}/scripts/build-on-root.cmake")
endfunction()


construct_tree(win32)
construct_tree(win64)
