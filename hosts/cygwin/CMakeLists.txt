# Native filesystem version

project(yunibuild-cygwin NONE)
cmake_minimum_required(VERSION 3.2)

add_custom_target(base)  # Update base environment
add_custom_target(image) # Build yunibase image
add_custom_target(init)  # Remove current yunibase image

add_custom_target(cygwin64_base
    COMMAND setup-x86_64.exe
    -s http://ftp.iij.ad.jp/pub/cygwin 
    -R ${CMAKE_CURRENT_BINARY_DIR}/cyg64 
    -l ${CMAKE_CURRENT_BINARY_DIR}/cache64 
    -B -v -q -N -d -g 
    -P libiconv-devel,libisl10,cloog-isl,cmake,git,gcc,make,gcc-g++,automake,autoconf,libtool,libgmp-devel,libonig-devel,flex,gettext-devel,pkg-config,libunistring-devel,libffi-devel,libgc-devel,texinfo,zlib-devel
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    USES_TERMINAL
    COMMENT "Installing base cygwin64 image...")

add_dependencies(base cygwin64_base)

add_custom_target(cygwin64_copyscript
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_LIST_DIR}/../../scripts/build-on-root.cmake ${CMAKE_CURRENT_BINARY_DIR}/cyg64
    )

add_custom_target(cygwin64_build
    COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_LIST_DIR}/runscript.cmake
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    USES_TERMINAL)

add_dependencies(cygwin64_build cygwin64_copyscript)

add_dependencies(image cygwin64_build)

if(NOT EXISTS setup-x86_64.exe)
    message(STATUS "Downloading Cygwin setup")
    file(DOWNLOAD
        "https://www.cygwin.com/setup-x86_64.exe"
        ./setup-x86_64.exe)
endif()
