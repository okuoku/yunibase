# Setup msys yunibuild

set(url_msys32 # Unused for now
    "http://downloads.sourceforge.net/project/msys2/Base/i686/msys2-base-i686-20150916.tar.xz")
set(url_msys64
    "http://downloads.sourceforge.net/project/msys2/Base/x86_64/msys2-base-x86_64-20150916.tar.xz")

file(MAKE_DIRECTORY build)

file(DOWNLOAD ${url_msys64} ./msys64.tar.xz)

# execute_process(COMMAND
#     "${CMAKE_COMMAND}" -E tar zxf msys32.tar.xz)
execute_process(COMMAND
    "${CMAKE_COMMAND}" -E tar zxf msys64.tar.xz)

file(RENAME msys64 build/msys64)

# Initial setup
execute_process(COMMAND
    cmd /C "sh" ../../etc/profile 
    RESULT_VARIABLE rr
    WORKING_DIRECTORY build/msys64/usr/bin)

if(rr)
    message(FATAL_ERROR "Failed to setup MSYS64 ${rr}")
endif()

# Install packages
file(COPY "${CMAKE_CURRENT_LIST_DIR}/setup-msys-initialupdate.sh"
    DESTINATION build/msys64)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/setup-msys-installtoolchains.sh"
    DESTINATION build/msys64)

execute_process(COMMAND
    cmd /C "sh" -l /setup-msys-initialupdate.sh
    RESULT_VARIABLE rr
    WORKING_DIRECTORY build/msys64/usr/bin)

if(rr)
    message(FATAL_ERROR "Failed to initial update ${rr}")
endif()


execute_process(COMMAND
    cmd /C "sh" -l /setup-msys-installtoolchains.sh
    RESULT_VARIABLE rr
    WORKING_DIRECTORY build/msys64/usr/bin)

if(rr)
    message(FATAL_ERROR "Failed to install toolchains ${rr}")
endif()


