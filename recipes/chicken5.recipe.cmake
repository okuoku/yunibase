# Recipe for chicken-scheme
#
#  - Chicken have no separate bootstrap build phase.
#    Just have some `chicken` and it should build automagically.
#  - Chicken (currently) cannot perform check until it has installed
#

if(CYGWIN)
    set(CHICKEN5_ARG_PLATFORM "PLATFORM=cygwin")
elseif(APPLE)
    set(CHICKEN5_ARG_PLATFORM "PLATFORM=macosx")
elseif(${CMAKE_SYSTEM_NAME} STREQUAL "FreeBSD")
    set(CHICKEN5_ARG_PLATFORM "PLATFORM=bsd" "C_COMPILER=cc")
elseif(WIN32)
    if(YUNIBASE_BOOTSTRAP_ONLY)
        set(CHICKEN5_ARG_PLATFORM "PLATFORM=mingw-msys")
    else()
        set(CHICKEN5_ARG_PLATFORM "PLATFORM=mingw")
    endif()
else()
    set(CHICKEN5_ARG_PLATFORM "PLATFORM=linux")
endif()
set(RECIPE_CHICKEN5 # Recipe for Chicken
    STEP "Build" # Chicken has no pallarel build support
    MAKE ${CHICKEN5_ARG_PLATFORM} "PREFIX=__INSTALL_PREFIX__"
    STEP "Install"
    MAKE ${CHICKEN5_ARG_PLATFORM} "PREFIX=__INSTALL_PREFIX__" install
)

set(RECIPE_CHICKEN5_TEST
    STEP "Test"      
    MAKE ${CHICKEN5_ARG_PLATFORM} "PREFIX=__INSTALL_PREFIX__" check
    TIMEOUT:600
)
set(RECIPE_CHICKEN5_SETUP
    STEP "SetupMatchable" ${CMAKE_COMMAND} 
    -DSRC=${YUNIBASE_ROOT_CURRENT}/chicken5-eggs/matchable
    -P ${CMAKE_CURRENT_SOURCE_DIR}/recipes/build-chicken-egg.cmake
    STEP "SetupSrfi1" ${CMAKE_COMMAND} 
    -DSRC=${YUNIBASE_ROOT_CURRENT}/chicken5-eggs/srfi-1
    -P ${CMAKE_CURRENT_SOURCE_DIR}/recipes/build-chicken-egg.cmake
    STEP "SetupSrfi14" ${CMAKE_COMMAND} 
    -DSRC=${YUNIBASE_ROOT_CURRENT}/chicken5-eggs/srfi-14
    -P ${CMAKE_CURRENT_SOURCE_DIR}/recipes/build-chicken-egg.cmake
    STEP "SetupSrfi13" ${CMAKE_COMMAND} 
    -DSRC=${YUNIBASE_ROOT_CURRENT}/chicken5-eggs/srfi-13
    -P ${CMAKE_CURRENT_SOURCE_DIR}/recipes/build-chicken-egg.cmake
    STEP "SetupSrfi69" ${CMAKE_COMMAND} 
    -DSRC=${YUNIBASE_ROOT_CURRENT}/chicken5-eggs/srfi-69
    -P ${CMAKE_CURRENT_SOURCE_DIR}/recipes/build-chicken-egg.cmake
    STEP "SetupR7RS" ${CMAKE_COMMAND} 
    -DSRC=${YUNIBASE_ROOT_CURRENT}/chicken5-eggs/chicken5-r7rs-svn
    -P ${CMAKE_CURRENT_SOURCE_DIR}/recipes/build-chicken-egg.cmake
)
