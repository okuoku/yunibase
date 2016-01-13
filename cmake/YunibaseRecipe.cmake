# YunibaseRecipe

# Recipe keywords:
#
#   __MAKE_OPTS__ : Translates into make "-j N" option
#   __INSTALL_PREFIX__ : Translates into option INSTALL_PREFIX
#   MAKE : Translates into posix make
#   GMAKE : Translates into GNU make
#
# Defined steps:
#
#   Bootstrap
#   Configure
#   Build
#   Test
#   Install

set(yunibase_recipe_replace_entries
    __MAKE_OPTS__      MAKE_OPTS
    __INSTALL_PREFIX__ INSTALL_PREFIX
    MAKE               MAKE
    GMAKE              GNU_MAKE
    )

macro(yunibase_recipe_replace_args_pair str_in str_out prefix nam ref)
    # Consume 2 args at once
    string(REGEX REPLACE "${nam}" "${${prefix}_${ref}}" ${str_out} "${str_in}")
    if(NOT "${str_in}" STREQUAL "${str_out}")
        # nothing to do
    elseif(NOT "${ARGN}" STREQUAL "") # Recurse if we still have any extra args
        # Try next entry
        # FIXME: Why can't this be just a if(ARGN)??
        yunibase_recipe_replace_args_pair(${str_in} ${str_out} ${prefix}
            ${ARGN})
    endif()
endmacro()

macro(yunibase_recipe_replace_args str_in str_out prefix)
    yunibase_recipe_replace_args_pair(${str_in} ${str_out} ${prefix}
        ${yunibase_recipe_replace_entries})
endmacro()


macro(yunibase_recipe_gen_commands var first)
    set(_cur ${first})
    foreach(e ${ARGN})
        set(_cur "${_cur} ${e}")
    endforeach()
    set(${var} "${_cur}")
endmacro()

macro(yunibase_recipe_step tgt runner_file srcdir envp stepname)
    yunibase_recipe_gen_commands(_cmd ${ARGN})
    file(APPEND ${runner_file}
        "run_step(${tgt} ${stepname} ${srcdir} ${CMAKE_CURRENT_BINARY_DIR}/logs/${tgt} \"${envp}\" ${_cmd})\n")
endmacro()

macro(build_recipe tgt source_dir prefix envp)
    set(_args)
    set(_runner_file
        "${CMAKE_CURRENT_BINARY_DIR}/recipe_runners/${tgt}.cmake")
    message(STATUS "runner: ${_runner_file}")
    # Generate runner header
    configure_file(${YUNIBASE_ROOT}/cmake/YunibaseRecipeRunner.in.cmake
        ${_runner_file} @ONLY)

    # Generate envp
    if(NOT "${envp}" STREQUAL "")
        file(APPEND ${_runner_file}
            "apply_envp(${envp})\n")
    endif()

    # Generate args
    foreach(e ${ARGN})
        set(_arg)
        yunibase_recipe_replace_args("${e}" _arg ${prefix})
        list(APPEND _args ${_arg})
    endforeach()

    # Generate runner body
    set(_reg)
    foreach(e ${_args})
        if(${e} STREQUAL "STEP")
            if(_reg)
                yunibase_recipe_step(${tgt} ${_runner_file} ${source_dir} "${envp}" ${_reg})
            endif()
            set(_reg)
        else()
            list(APPEND _reg "${e}")
        endif()
    endforeach()
    if(_reg) # Process the last step
        yunibase_recipe_step(${tgt} ${_runner_file} ${source_dir} "${envp}" ${_reg})
        set(_reg)
    endif()

    # Invoke runner
    add_custom_target(${tgt} ALL
        COMMAND ${CMAKE_COMMAND} -P ${_runner_file}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Running ${_runner_file}"
        )
endmacro()

