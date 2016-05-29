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
    STEP "Setup"
    chicken-install r7rs
)
