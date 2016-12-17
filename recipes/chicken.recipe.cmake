# Recipe for chicken-scheme
#
#  - Chicken have no separate bootstrap build phase.
#    Just have some `chicken` and it should build automagically.
#  - Chicken (currently) cannot perform check until it has installed
#

if(CYGWIN)
    set(CHICKEN_ARG_PLATFORM "PLATFORM=cygwin")
elseif(APPLE)
    set(CHICKEN_ARG_PLATFORM "PLATFORM=macosx")
elseif(${CMAKE_SYSTEM_NAME} STREQUAL "FreeBSD")
    set(CHICKEN_ARG_PLATFORM "PLATFORM=bsd" "C_COMPILER=cc")
elseif(WIN32)
    if(YUNIBASE_BOOTSTRAP_ONLY)
        set(CHICKEN_ARG_PLATFORM "PLATFORM=mingw-msys")
    else()
        set(CHICKEN_ARG_PLATFORM "PLATFORM=mingw")
    endif()
else()
    set(CHICKEN_ARG_PLATFORM "PLATFORM=linux")
endif()
set(RECIPE_CHICKEN # Recipe for Chicken
    STEP "Build" # Chicken has no pallarel build support
    MAKE ${CHICKEN_ARG_PLATFORM} "PREFIX=__INSTALL_PREFIX__"
    STEP "Install"
    MAKE ${CHICKEN_ARG_PLATFORM} "PREFIX=__INSTALL_PREFIX__" install
)

set(RECIPE_CHICKEN_TEST
    STEP "Test"      
    MAKE ${CHICKEN_ARG_PLATFORM} "PREFIX=__INSTALL_PREFIX__" check
    TIMEOUT:600
)
set(RECIPE_CHICKEN_SETUP
    STEP "SetupMake" ${CMAKE_COMMAND} 
    -DSRC=${YUNIBASE_ROOT_CURRENT}/chicken-eggs/chicken-r7rs-deps/make
    -P ${CMAKE_CURRENT_SOURCE_DIR}/recipes/build-chicken-egg.cmake
    STEP "SetupMatchable" ${CMAKE_COMMAND} 
    -DSRC=${YUNIBASE_ROOT_CURRENT}/chicken-eggs/chicken-r7rs-deps/matchable
    -P ${CMAKE_CURRENT_SOURCE_DIR}/recipes/build-chicken-egg.cmake
    STEP "SetupNumbers" ${CMAKE_COMMAND} 
    -DSRC=${YUNIBASE_ROOT_CURRENT}/chicken-eggs/chicken-r7rs-deps/numbers
    -P ${CMAKE_CURRENT_SOURCE_DIR}/recipes/build-chicken-egg.cmake
    STEP "SetupR7RS" ${CMAKE_COMMAND} 
    -DSRC=${YUNIBASE_ROOT_CURRENT}/chicken-eggs/chicken-r7rs
    -P ${CMAKE_CURRENT_SOURCE_DIR}/recipes/build-chicken-egg.cmake
)
