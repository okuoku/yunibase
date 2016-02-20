set(RECIPE_LARCENY
    STEP "Build"     ${CMAKE_COMMAND} -DPREFIX=__INSTALL_PREFIX__ -P
    ${CMAKE_CURRENT_SOURCE_DIR}/recipes/build-larceny.cmake
)

