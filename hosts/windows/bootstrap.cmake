# Bootstrap for yunibase build environment for Windows(native)

set(url_ninja "https://github.com/ninja-build/ninja/releases/download/v1.6.0/ninja-win.zip")
set(name_cmake "cmake-3.4.3-win32-x86")
set(url_cmake "https://cmake.org/files/v3.4/${name_cmake}.zip")

file(DOWNLOAD ${url_ninja} ./ninja.zip)
file(DOWNLOAD ${url_cmake} ./cmake.zip)

execute_process(COMMAND 
    "${CMAKE_COMMAND}" -E tar zxf ninja.zip)
execute_process(COMMAND
    "${CMAKE_COMMAND}" -E tar zxf cmake.zip)

file(RENAME ${name_cmake} build)
file(RENAME ninja.exe build/bin/ninja.exe)
