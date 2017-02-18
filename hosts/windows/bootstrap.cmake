# Bootstrap for yunibase build environment for Windows(native)

set(url_ninja "https://github.com/ninja-build/ninja/releases/download/v1.7.2/ninja-win.zip")
set(name_cmake "cmake-3.7.2-win64-x64")
set(url_cmake "https://cmake.org/files/v3.7/${name_cmake}.zip")

file(MAKE_DIRECTORY archives)

file(DOWNLOAD ${url_ninja} archives/ninja.zip)
file(DOWNLOAD ${url_cmake} archives/cmake.zip)

execute_process(COMMAND 
    "${CMAKE_COMMAND}" -E tar zxf archives/ninja.zip)
execute_process(COMMAND
    "${CMAKE_COMMAND}" -E tar zxf archives/cmake.zip)

file(RENAME ${name_cmake} build)
file(RENAME ninja.exe build/bin/ninja.exe)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/envsetup.bat
    DESTINATION .)
