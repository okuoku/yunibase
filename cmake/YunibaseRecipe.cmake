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

macro(yunibase_recipe_step tgt runner_file srcdir envp timeout stepname)
    yunibase_recipe_gen_commands(_cmd ${ARGN})
    file(APPEND ${runner_file}
        "run_step(${tgt} ${stepname} ${srcdir} ${YUNIBASE_BUILD_CONFIG_PREFIX}/${tgt} ${YUNIBASE_BUILD_REPORT_PREFIX} ${YUNIBASE_BUILD_LOG_PREFIX}/${tgt} \"${envp}\" ${timeout} ${_cmd})\n")
    file(APPEND ${YUNIBASE_BUILD_REPORT_PREFIX}/${tgt}.cmake
        "list(APPEND ${tgt}_steps \"${stepname}\")\n")
    file(APPEND ${YUNIBASE_BUILD_REPORT_PREFIX}/${tgt}.cmake
        "include(\"${YUNIBASE_BUILD_REPORT_PREFIX}/${tgt}_${stepname}_report.cmake\" OPTIONAL)\n")
endmacro()

macro(yunibase_recipe_set_default_opts prefix)
    if(YUNIBASE_USE_GMAKE)
        set(_mymake gmake)
    else()
        set(_mymake make)
    endif()
    if(NOT ${prefix}_MAKE)
        set(${prefix}_MAKE ${_mymake})
    endif()
    if(NOT ${prefix}_MAKE_OPTS)
        set(${prefix}_MAKE_OPTS "")
    endif()
endmacro()

macro(build_recipe tgt source_dir install_dir prefix envp)
    set(${prefix}_INSTALL_PREFIX ${install_dir})
    yunibase_recipe_set_default_opts(${prefix})
    set(_args)
    set(_runner_file
        "${CMAKE_CURRENT_BINARY_DIR}/recipe_runners/${tgt}.cmake")
    # message(STATUS "runner: ${_runner_file}")
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

    # Generate result top file
    file(WRITE ${YUNIBASE_BUILD_REPORT_PREFIX}/${tgt}.cmake
        "# Report top for ${tgt}\nset(${tgt}_steps)\n")

    # Generate runner body
    set(_reg)
    set(_reg_timeout 0)
    foreach(e ${_args})
        if(${e} STREQUAL "STEP")
            if(_reg)
                yunibase_recipe_step(${tgt} ${_runner_file} ${source_dir} "${envp}" ${_reg_timeout} ${_reg})
            endif()
            set(_reg)
            set(_reg_timeout 0)
        elseif(${e} MATCHES "TIMEOUT:(.*)")
            set(_reg_timeout ${CMAKE_MATCH_1})
        else()
            list(APPEND _reg "${e}")
        endif()
    endforeach()
    if(_reg) # Process the last step
        yunibase_recipe_step(${tgt} ${_runner_file} ${source_dir} "${envp}" ${_reg_timeout} ${_reg})
        set(_reg)
        set(_reg_timeout 0)
    endif()

    # Invoke runner
    add_custom_target(${tgt}
        COMMAND ${CMAKE_COMMAND} -P ${_runner_file}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Running ${_runner_file}"
        )
endmacro()

