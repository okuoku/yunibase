# Native filesystem version

project(yunibuild-cygwin NONE)
cmake_minimum_required(VERSION 3.2)

set(url_msys32 # Unused for now
    "http://downloads.sourceforge.net/project/msys2/Base/i686/msys2-base-i686-20150916.tar.xz")
set(url_msys64
    "http://downloads.sourceforge.net/project/msys2/Base/x86_64/msys2-base-x86_64-20150916.tar.xz")

add_custom_target(base)  # Update base environment
add_custom_target(image) # Build yunibase image
add_custom_target(init)  # Remove current yunibase image

#
# CYGWIN
#

add_custom_target(cygwin64_base
    COMMAND archives/setup-x86_64.exe
    -s http://ftp.iij.ad.jp/pub/cygwin 
    -R ${CMAKE_CURRENT_BINARY_DIR}/cyg64 
    -l ${CMAKE_CURRENT_BINARY_DIR}/cache64 
    -B -v -q -N -d -g 
    -P libiconv-devel,libisl10,cloog-isl,cmake,git,gcc,make,gcc-g++,automake,autoconf,libtool,libgmp-devel,libonig-devel,flex,gettext-devel,pkg-config,libunistring-devel,libffi-devel,libgc-devel,texinfo,zlib-devel
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    USES_TERMINAL
    COMMENT "Installing base cygwin64 image...")

add_dependencies(base cygwin64_base)

add_custom_target(cygwin64_imageclean
    COMMAND ${CMAKE_COMMAND} -E remove_directory 
    ${CMAKE_CURRENT_BINARY_DIR}/cyg64/yunisrc
    COMMAND ${CMAKE_COMMAND} -E remove_directory 
    ${CMAKE_CURRENT_BINARY_DIR}/cyg64/build
    COMMENT "Removing previous images...")

add_custom_target(cygwin64_build
    COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_LIST_DIR}/cygwin-run-build.cmake
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    USES_TERMINAL)

add_dependencies(cygwin64_build cygwin64_imageclean)
add_dependencies(image cygwin64_build)

# 
# MSYS
#

add_custom_target(msys64_base0
    COMMAND "${CMAKE_COMMAND}" -E tar zxf archives/msys64.tar.xz
    COMMAND "${CMAKE_COMMAND}" -E copy
    ${CMAKE_CURRENT_LIST_DIR}/setup-msys-initialupdate.sh
    ${CMAKE_CURRENT_BINARY_DIR}/msys64
    COMMAND "${CMAKE_COMMAND}" -E copy
    ${CMAKE_CURRENT_LIST_DIR}/setup-msys-installtoolchains.sh
    ${CMAKE_CURRENT_BINARY_DIR}/msys64
    USES_TERMINAL
    COMMENT "Unpacking MSYS64 base image..."
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})

add_custom_target(msys64_base1
    COMMAND cmd /C "sh" -l /setup-msys-initialupdate.sh
    USES_TERMINAL
    COMMENT "Performing initial update..."
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/msys64/usr/bin)

add_custom_target(msys64_base2
    COMMAND cmd /C "sh" -l /setup-msys-installtoolchains.sh
    USES_TERMINAL
    COMMENT "Installing toolchains..."
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/msys64/usr/bin)

add_custom_target(msys64_base)
add_dependencies(msys64_base msys64_base2)
add_dependencies(msys64_base2 msys64_base1)
add_dependencies(msys64_base1 msys64_base0)

add_dependencies(base msys64_base)

#
# Download prerequisites
#
#
file(MAKE_DIRECTORY archives)
if(NOT EXISTS archives/setup-x86_64.exe)
    message(STATUS "Downloading Cygwin setup")
    file(DOWNLOAD
        "https://www.cygwin.com/setup-x86_64.exe"
        archives/setup-x86_64.exe)
endif()

if(NOT EXISTS archives/msys64.tar.xz)
    message(STATUS "Downloading MSYS base image")
    file(DOWNLOAD ${url_msys64} archives/msys64.tar.xz)
endif()
