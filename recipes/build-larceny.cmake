# Build larceny using larceny binary distribution on Linux32
#
# INPUTs:
#   PREFIX: destination prefix

if(NOT PREFIX)
    message(FATAL_ERROR "huh?")
endif()

set(bin_basename
    larceny-0.99-bin-native-ia32-linux86)

set(archive_basename
    larceny-bin.tar.gz)

set(url_larceny_bin
    http://www.larcenists.org/LarcenyReleases/${bin_basename}.tar.gz)

#
# Cleanup current build
#

file(GLOB_RECURSE fasls src/*.fasl lib/*.fasl)
message(STATUS "Removing current build(fasl)...")
foreach(e ${fasls})
    message(STATUS "${e}")
    file(REMOVE "${e}")
endforeach()



# Download and expand binary distribution

message(STATUS "Downloading Larceny binary(${url_larceny_bin})...")
#file(DOWNLOAD 
#    ${url_larceny_bin} ./${archive_basename}
#    SHOW_PROGRESS LOG mm)
#
#message(STATUS "Log: ${mm}")
execute_process(
    COMMAND wget -O ${archive_basename} ${url_larceny_bin}
    RESULT_VARIABLE rr)

if(rr)
    message(FATAL_ERROR "wget: ${rr}")
endif()

message(STATUS "Extract Larceny binary...")
execute_process(
    COMMAND ${CMAKE_COMMAND} -E tar zxf ${archive_basename}
    RESULT_VARIABLE rr)

#
# Output files
#

set(iasn_heap src/Build/iasn-larceny-heap.fasl)

#
# STEP0: Cleanup current image
#

file(REMOVE ${iasn_heap})

#
# STEP1: Build larceny core
#

file(WRITE empty.bin)

file(WRITE step1.scm
    "(load \"setup.sch\")
(setup 'scheme: 'larceny 'host: 'linux86 'sassy 'string-rep: 'flat4)
(build-config-files)
(load-compiler)
(build-heap)
(build-runtime)
(build-executable)
(build-larceny-files)
(exit)
")

message(STATUS "Step1...")

execute_process(
    COMMAND ${bin_basename}/larceny
    --
    step1.scm
    INPUT_FILE empty.bin
    RESULT_VARIABLE rr)

if(NOT EXISTS ${iasn_heap})
    message(FATAL_ERROR "Step1 did not generate ${iasn_heap}")
endif()

if(rr)
    message(FATAL_ERROR "Something wrong(${rr})")
endif()


#
# STEP2: Build larceny heap images
#

file(WRITE step2.scm
    "(exit)\n")

message(STATUS "Step2(larceny)...")


execute_process(
    COMMAND ./larceny.bin
    -stopcopy -- ${iasn_heap}
    RESULT_VARIABLE rr
    INPUT_FILE step2.scm)

if(rr)
    message(FATAL_ERROR "Something wrong(${rr})")
endif()

# message(STATUS "Step2(twobit)...")
# 
# execute_process(
#     COMMAND ./larceny.bin
#     -stopcopy -- src/Build/iasn-twobit-heap.fasl
#     RESULT_VARIABLE rr
#     INPUT_FILE step2.scm)
# 
# if(rr)
#     message(FATAL_ERROR "Something wrong(${rr})")
# endif()


#
# STEP3: Build larceny runtime
#

file(WRITE step3.scm
    "(require 'r7rsmode)
(error-handler
  (lambda err
    (display \"ERROR:\\n\" (current-error-port))
    (decode-error err (current-error-port))
    (newline (current-error-port))
    (exit 1)))
(larceny:compile-r7rs-runtime)
(exit)
")

set(ENV{LARCENY_ROOT}
    ${CMAKE_CURRENT_BINARY_DIR})


message(STATUS "Step3...")

execute_process(
    COMMAND ./larceny
    -- step3.scm
    RESULT_VARIABLE rr)

if(rr)
    message(FATAL_ERROR "Something wrong(${rr})")
endif()

message(STATUS "Copy ${CMAKE_CURRENT_BINARY_DIR} => ${PREFIX}")

file(MAKE_DIRECTORY ${PREFIX})

get_filename_component(repos_basename ${CMAKE_CURRENT_BINARY_DIR} NAME)

file(COPY
    ${CMAKE_CURRENT_BINARY_DIR}
    DESTINATION
    ${PREFIX}
    PATTERN ".git" EXCLUDE
    PATTERN ${archive_basename} EXCLUDE
    PATTERN ${bin_basename} EXCLUDE)

if(IS_DIRECTORY ${PREFIX}/bin)
    file(REMOVE_RECURSE ${PREFIX}/bin)
elseif(EXISTS ${PREFIX}/bin)
    message(FATAL_ERROR "What??")
endif()

file(RENAME ${PREFIX}/${repos_basename} ${PREFIX}/bin)

message(STATUS "Done.")

