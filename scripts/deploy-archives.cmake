#
# Deploy prebuilt archives to directories
#
# INPUTs:
#   YUNIBASEROOT: Root path
#   ARCHIVEPREFIX: Archive tag prefix (yunibase_ARCHIVEPREFIX_*_current.tar.gz)
#   ARCHIVEDIR: Archive directory
#

file(GLOB archives ${ARCHIVEDIR}/yunibase_${ARCHIVEPREFIX}_*_current.tar.gz)

file(MAKE_DIRECTORY ${YUNIBASEROOT}/current)

foreach(ar ${archives})
    message(STATUS "Archive: ${ar}")
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar xvf ${ar}
        RESULT_VARIABLE rr
        WORKING_DIRECTORY ${YUNIBASEROOT}/current)
    if(rr)
        message(FATAL_ERROR "Error (${rr})")
    endif()
endforeach()

message(STATUS "Done.")
